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
  count                       = length(var.private_subnet_cidrs)
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = false
  subnet_id                   = element(aws_subnet.private_subnets.*.id, count.index)
  vpc_security_group_ids      = [aws_security_group.sg-wordpress.id]
  key_name                    = "tfkey"

  tags = {
    Name = "Wordpress EC2 ${count.index + 1}"
  }

  user_data = file("script.sh")
}


resource "aws_db_instance" "wordpress-db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = var.dbpass
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.mysql.id]
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name

}

resource "aws_db_subnet_group" "db-subnet" {
  subnet_ids = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id, aws_subnet.private_subnets[2].id]
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
