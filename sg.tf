locals {
  http_ports      = [80, 443]
  outbound_ports  = [0]
  wordpress_ports = [22]
}

#SGs

resource "aws_security_group" "sg-ec2" {
  name        = "ec2-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "SG for EC2 Instance"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = [aws_security_group.endpoint-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG EC2"
  }
}

resource "aws_security_group" "endpoint-sg" {
  name        = "Endpoint-SG"
  description = "Allow outbound SSH"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "alb-sg" {
  name        = "ALB-SG"
  description = "HTTP/S for ALB"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = local.http_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.sg-ec2.id]
  }

  tags = {
    Name = "HTTP/s for ALB"
  }
}