resource "aws_lb_target_group" "awd-tg" {
  name     = "EC2-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "target_attach" {
  count            = length(var.private_subnet_cidrs)
  target_group_arn = aws_lb_target_group.awd-tg.arn
  target_id        = element(aws_instance.ec2[*].id, count.index)
  port             = 80
}

resource "aws_lb" "alb" {
  name               = "EC2-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]

  enable_deletion_protection = false


  tags = {
    Environment = "EC2 ALB"
  }
}

resource "aws_lb_listener" "alb-list" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.awd-tg.arn
  }
}