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
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:Start*",
          "ec2:Stop*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-attach" {
  role       = aws_iam_role.lambdarole.name
  policy_arn = aws_iam_policy.lambdapolicy.arn
}