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

resource "aws_s3_bucket" "devbucket" {
  bucket        = var.devbucket
  force_destroy = true

  tags = {
    Name = "Development S3 Bucket"
  }
}

resource "aws_s3_bucket" "prodbucket" {
  bucket        = var.prodbucket
  force_destroy = true

  tags = {
    Name = "Production S3 Bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3dev_owner" {
  bucket = aws_s3_bucket.devbucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_ownership_controls" "s3prod_owner" {
  bucket = aws_s3_bucket.prodbucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "DevBucketACL" {
  bucket     = aws_s3_bucket.devbucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3dev_owner]
}

resource "aws_s3_bucket_acl" "ProdBucketACL" {
  bucket     = aws_s3_bucket.prodbucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3prod_owner]
}



resource "aws_instance" "dev_ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnets.id
  vpc_security_group_ids      = [aws_security_group.http-sg.id, aws_security_group.allow_ssh.id]
  key_name                    = "tfkey"
  iam_instance_profile        = aws_iam_instance_profile.ec2_iamprofile.name

  tags = {
    Name = "EC2 Dev"
  }

  user_data = file("script.sh")
}

resource "aws_instance" "prod_ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnets.id
  vpc_security_group_ids      = [aws_security_group.http-sg.id, aws_security_group.allow_ssh.id]
  key_name                    = "tfkey"
  iam_instance_profile        = aws_iam_instance_profile.ec2_iamprofile.name

  tags = {
    Name = "EC2 Prod"
  }

  user_data = file("script.sh")
}



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
