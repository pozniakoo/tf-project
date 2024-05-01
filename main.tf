terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}



resource "aws_codestarconnections_connection" "connection" {
  name          = "connection"
  provider_type = "GitHub"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "" #Enter your dev bucket name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "s3own" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket     = aws_s3_bucket.codepipeline_bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3own]
}



resource "aws_instance" "ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnets.id
  vpc_security_group_ids      = [aws_security_group.http-sg.id, aws_security_group.allow_ssh.id]
  key_name                    = "tfkey"
  iam_instance_profile        = aws_iam_instance_profile.ec2_iamprofile.name

  tags = {
    Name = "EC2 for CD"
  }

  user_data = file("script.sh")
}
#echo “Hello World from $(hostname -f)” > /usr/share/nginx/html/index.html



resource "aws_key_pair" "tfkey" {
  key_name   = "tfkey"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "tfkey"
}
