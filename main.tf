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


resource "aws_dynamodb_table" "dynamo-table" {
  name           = "serverless-app"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "views" {
  table_name = aws_dynamodb_table.dynamo-table.name
  hash_key   = aws_dynamodb_table.dynamo-table.hash_key

  item = jsonencode({
    "id" : {
      "S" : "0"
    },
    "views" : {
      "N" : "0"
    },
  })
}

resource "aws_s3_bucket" "webapp-bucket" {
  bucket = var.bucket
}


resource "aws_s3_object" "webapp-object" {
  for_each = fileset("webapp/", "*")

  bucket       = aws_s3_bucket.webapp-bucket.id
  key          = each.value
  source       = "webapp/${each.value}"
  depends_on   = [local_file.webapp_files]
  content_type = each.value == "style.css" ? "text/css" : each.value == "script.js" ? "application/javascript" : each.value == "index.html" ? "text/html" : each.value == "login.html" ? "text/html" : each.value == "logout.html" ? "text/html" : each.value == "image.jpg" ? "image/jpeg" : "application/octet-stream"
}


data "template_file" "webapp_files" {
  for_each = toset(var.webapp_files)
  template = file("${path.module}/templates/${each.key}.tpl")

  vars = {
    lambda_url = aws_lambda_function_url.app-url.function_url
    login_url  = "https://${var.cogdomain}.auth.${var.region}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.pool-client.id}&response_type=code&scope=email+openid+profile&redirect_uri=https%3A%2F%2F${var.greeting}%2Flogin.html"
    logout_url = "https://${var.cogdomain}.auth.${var.region}.amazoncognito.com/logout?client_id=${aws_cognito_user_pool_client.pool-client.id}&logout_uri=https%3A%2F%2F${var.greeting}%2Flogout.html"
  }
}

resource "local_file" "webapp_files" {
  for_each   = data.template_file.webapp_files
  filename   = "${path.module}/webapp/${each.key}"
  content    = each.value.rendered
  depends_on = [null_resource.webapp_files]
}

resource "null_resource" "webapp_files" {
  for_each = toset(var.webapp_files)

  triggers = {
    script_exists = fileexists("${path.module}/webapp/${each.key}")
  }
}

resource "aws_lambda_function" "app-function" {

  filename      = "lambda-function.zip"
  function_name = "lambda-function"
  role          = aws_iam_role.lambdarole.arn
  handler       = "lambda-function.lambda_handler"

  source_code_hash = filebase64sha256("lambda-function.zip")

  runtime = "python3.12"
  timeout = 63
}

resource "aws_iam_role" "lambdarole" {
  name = "RoleForLambda"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "Lambda Role"
  }
}

resource "aws_iam_policy" "lambdapolicy" {
  name        = "lambdapolicy"
  path        = "/"
  description = "Policy for Lambda"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource" : "${aws_dynamodb_table.dynamo-table.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-attach" {
  role       = aws_iam_role.lambdarole.name
  policy_arn = aws_iam_policy.lambdapolicy.arn
}

resource "aws_lambda_function_url" "app-url" {
  function_name      = aws_lambda_function.app-function.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["https://${var.greeting}"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

