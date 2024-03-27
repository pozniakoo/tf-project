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
  bucket = "szymon12345-webapp-bucket"
}


resource "aws_s3_object" "webapp-object" {
  for_each = fileset("webapp/", "*")

  bucket = aws_s3_bucket.webapp-bucket.id
  key    = each.value
  source = "webapp/${each.value}"
  etag   = filemd5("webapp/${each.value}")
  depends_on = [local_file.script]
  content_type = each.value == "style.css" ? "text/css" : each.value == "script.js" ? "application/javascript" : each.value == "index.html" ? "text/html" : "application/octet-stream"
}



resource "aws_s3_bucket_policy" "cloudfront_s3_bucket_policy" {
  bucket = aws_s3_bucket.webapp-bucket.id
  policy = jsonencode({
    Version = "2008-10-17"
    Id      = "PolicyForCloudFrontPrivateContent"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.webapp-bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "${aws_cloudfront_distribution.s3_distribution.arn}"
          }
        }
      }
    ]
  })
}

data "template_file" "script_js" {
  template = "${file("${path.module}/script.js.tpl")}"

  vars = {
    lambda_url = aws_lambda_function_url.test_live.function_url
  }
}

/*resource "aws_s3_object" "script" {
  bucket = aws_s3_bucket.webapp-bucket.id
  key    = "script.js"
  source = data.template_file.script_js.rendered

  content_type = "application/javascript"
}
*/
resource "null_resource" "local_script" {
  triggers = {
    script_exists = fileexists("${path.module}/webapp/script.js")
  }
}

resource "local_file" "script" {
  filename = "${path.module}/webapp/script.js"
  content  = data.template_file.script_js.rendered
  depends_on = [null_resource.local_script]
}

resource "aws_lambda_function" "stop-ec2" {

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
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Action": [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        "Resource": "${aws_dynamodb_table.dynamo-table.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-attach" {
  role       = aws_iam_role.lambdarole.name
  policy_arn = aws_iam_policy.lambdapolicy.arn
}

resource "aws_lambda_function_url" "test_live" {
  function_name      = aws_lambda_function.stop-ec2.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["https://greeting.${var.adres}"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

output "Lambda-URL" {
  value = aws_lambda_function_url.test_live.function_url
}
#allow_origins     = ["https://${aws_s3_bucket.webapp-bucket.bucket_regional_domain_name}"]


#aws_cloudfront_distribution.s3_distribution.alterna