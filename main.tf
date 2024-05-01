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

resource "aws_instance" "wordpress" {
  count                       = length(var.public_subnet_cidrs)
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.public_subnets.*.id, count.index)
  vpc_security_group_ids      = [aws_security_group.http-sg.id, aws_security_group.allow_ssh.id]
  key_name                    = "TF_key"

  tags = {
    Name = "Wordpress EC2 ${count.index + 1}"
  }

  user_data = file("script.sh")
}

resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
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
