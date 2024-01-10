locals {
  http_ports      = [80, 443]
  outbound_ports  = [0]
  wordpress_ports = [22]
}

#SGs

resource "aws_security_group" "sg-wordpress" {
  name        = "wordpress-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "SG for Wordpress EC2 Instance"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = [aws_security_group.alb-sg.id]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = [aws_security_group.endpoint-sg.id]
  }
  dynamic "ingress" {
    for_each = local.http_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  }

  dynamic "egress" {
    for_each = local.outbound_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name = "SG Wordpress"
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
    cidr_blocks = ["0.0.0.0/0"]
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

  dynamic "egress" {
    for_each = local.outbound_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name = "HTTP/s for ALB"
  }
}

resource "aws_security_group" "mysql" {
  name        = "mysql-sg"
  description = "MySQL SG"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "MySQL SG"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = ["${aws_security_group.sg-wordpress.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

