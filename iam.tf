resource "aws_iam_role" "roleforec2" {
  name = "RoleForEC2"
  assume_role_policy = jsonencode({
    "Statement": [
          {
              "Action": [
                  "sts:AssumeRole"
              ],
              "Effect": "Allow",
              "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
          }
      ]
  })
}





resource "aws_iam_role" "CPRole" {
  name = "RoleForCP"
  assume_role_policy = jsonencode({
    "Statement": [
          {
              "Action": [
                  "sts:AssumeRole"
              ],
              "Effect": "Allow",
              "Principal": {
                "Service": [
                    "codepipeline.amazonaws.com"
                ]
            }
          }
      ]
  })
}

resource "aws_iam_role" "CDRole" {
  name = "RoleForCD"
  assume_role_policy = jsonencode({
    "Statement": [
          {
              "Action": [
                  "sts:AssumeRole"
              ],
              "Effect": "Allow",
              "Principal": {
                "Service": [
                    "codedeploy.amazonaws.com"
                ]
            }
          }
      ]
  })
}

resource "aws_iam_policy" "PolicyforCP" {
  name        = "CPolicy"
  path        = "/"
  description = "Policy for CodePipeline"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "codestar-connections:UseConnection",
          "codepipeline:*",
          "codebuild:BatchGetProjects",
            "codebuild:CreateProject",
            "codebuild:ListCuratedEnvironmentImages",
            "codebuild:ListProjects",
            "codecommit:ListBranches",
            "codecommit:GetReferences",
            "codecommit:ListRepositories",
            "codedeploy:BatchGetDeploymentGroups",
            "codedeploy:ListApplications",
            "codedeploy:ListDeploymentGroups",
            "codedeploy:CreateDeployment",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:RegisterApplicationRevision",
            "codedeploy:GetDeployment",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "codedeploy:GetApplicationRevision",
            "ec2:DescribeVpcs",
            "ecr:DescribeRepositories",
            "s3:ListAllMyBuckets",
            "states:ListStateMachines",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning",
            "s3:PutObjectAcl",
            "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}




resource "aws_iam_instance_profile" "ec2_iamprofile" {
  name = "ec2_profile"
  role = aws_iam_role.roleforec2.name
}
resource "aws_iam_role_policy_attachment" "EC2Role" {
  role = aws_iam_role.roleforec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}
resource "aws_iam_role_policy_attachment" "CDRoleAttach" {
  role = aws_iam_role.CDRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}
resource "aws_iam_role_policy_attachment" "CPRoleAttach" {
  role = aws_iam_role.CPRole.name
  policy_arn = aws_iam_policy.PolicyforCP.arn
}
