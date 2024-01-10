resource "aws_codedeploy_app" "cdapp" {
  name = "CDApp"
}

resource "aws_codedeploy_deployment_group" "cdtfgroup" {
  app_name              = aws_codedeploy_app.cdapp.name
  deployment_group_name = "CDDDeploymentGroup"
  service_role_arn      = aws_iam_role.CDRole.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "EC2 for CD"
    }
  }


}

resource "aws_codestarconnections_connection" "cscon" {
  name          = "GitHub-Connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "CPipeline"
  role_arn = aws_iam_role.CPRole.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "" #Enter your CodeStar connection ARN
        FullRepositoryId = "" #Enter your Repository path
        BranchName       = "" #Enter your Dev branch name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ApplicationName = "CDApp"
        DeploymentGroupName = "CDDDeploymentGroup"
      }
    }
  }
}
