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


resource "aws_instance" "ec2instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = "tfkey"

  tags = {
    Name = "Main EC2 Instance"
  }

  user_data = file("script.sh")
}



resource "aws_ami_from_instance" "ec2ami" {
  name = "ec2ami"

  source_instance_id = aws_instance.ec2instance.id

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

resource "aws_instance" "backup_instance" {
  ami                    = aws_ami_from_instance.ec2ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = "tfkey"

  tags = {
    Name = "Backup EC2 Instance"
  }
}

resource "aws_key_pair" "TF_key" {
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
