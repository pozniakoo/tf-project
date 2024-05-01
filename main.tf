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


resource "aws_instance" "EC2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnets.id
  vpc_security_group_ids      = [aws_security_group.http-sg.id, aws_security_group.allow_ssh.id]
  key_name                    = "tfkey"

  tags = {
    Name = "EC2 instance"
  }

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

resource "aws_lambda_function" "stop-ec2" {

  filename      = "lambda-stop.zip"
  function_name = "lambda-stop"
  role          = aws_iam_role.lambdarole.arn
  handler       = "lambda-stop.lambda_handler"

  source_code_hash = filebase64sha256("lambda-stop.zip")

  runtime = "python3.7"
  timeout = 63
}

resource "aws_cloudwatch_event_rule" "stop-ec2" {
  name                = "stop-ec2"
  description         = "EC2 stop instance"
  schedule_expression = "cron(0 11 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda-stop" {
  target_id = "lambda"
  rule      = aws_cloudwatch_event_rule.stop-ec2.name
  arn       = aws_lambda_function.stop-ec2.arn
}

resource "aws_lambda_permission" "stop-perm" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop-ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop-ec2.arn
}

resource "aws_lambda_function" "start-ec2" {

  filename      = "lambda-start.zip"
  function_name = "lambda-start"
  role          = aws_iam_role.lambdarole.arn
  handler       = "lambda-start.lambda_handler"

  source_code_hash = filebase64sha256("lambda-start.zip")

  runtime = "python3.7"
  timeout = 63
}

resource "aws_cloudwatch_event_rule" "start-ec2" {
  name                = "start-ec2"
  description         = "EC2 start instance"
  schedule_expression = "cron(15 11 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda-start" {
  target_id = "lambda"
  rule      = aws_cloudwatch_event_rule.start-ec2.name
  arn       = aws_lambda_function.start-ec2.arn
}

resource "aws_lambda_permission" "start-perm" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start-ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start-ec2.arn
}