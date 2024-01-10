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



resource "aws_instance" "ec2" {
  count                       = length(var.private_subnet_cidrs)
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = false
  subnet_id                   = element(aws_subnet.private_subnets.*.id, count.index)
  vpc_security_group_ids      = [aws_security_group.sg-ec2.id]
  key_name                    = "tfkey"

  tags = {
    Name = "EC2 ${count.index + 1}"
  }

  user_data = file("script.sh")
}


resource "aws_ec2_instance_connect_endpoint" "endpoint" {
  subnet_id          = aws_subnet.private_subnets[1].id
  security_group_ids = [aws_security_group.endpoint-sg.id]
  preserve_client_ip = false
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
