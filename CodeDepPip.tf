resource "aws_codedeploy_app" "CDDevApp" {
  name = "CodeDeployDevApp"
}

resource "aws_codedeploy_app" "CDProdApp" {
  name = "CodeDeployProdApp"
}

resource "aws_codedeploy_deployment_group" "CDDevGroup" {
  app_name              = aws_codedeploy_app.CDDevApp.name
  deployment_group_name = "CDDeployGroupForDEV"
  service_role_arn      = aws_iam_role.CDRole.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "EC2 Dev"
    }
  }
}

resource "aws_codedeploy_deployment_group" "CDProdGroup" {
  app_name              = aws_codedeploy_app.CDProdApp.name
  deployment_group_name = "CDDeployGroupForProd"
  service_role_arn      = aws_iam_role.CDRole.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "EC2 Prod"
    }
  }
}

resource "aws_codestarconnections_connection" "CodeStarConnection" {
  name          = "GitHub-Connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "DevCodePipeline" {
  name     = "DevCodePipeline"
  role_arn = aws_iam_role.CPRole.arn

  artifact_store {
    location = aws_s3_bucket.devbucket.bucket
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
        ConnectionArn    = "arn:aws:codestar-connections:us-east-1:563539093289:connection/804203dc-6978-4a51-a29e-7aa51c170be8"
        FullRepositoryId = "pozniakoo/trening"
        BranchName       = "dev"
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
        ApplicationName = "CodeDeployDevApp"
        DeploymentGroupName = "CDDeployGroupForDEV"
      }
    }
  }
}


resource "aws_codepipeline" "ProdCodePipeline" {
  name     = "ProdCodePipeline"
  role_arn = aws_iam_role.CPRole.arn

  artifact_store {
    location = aws_s3_bucket.prodbucket.bucket
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
        ConnectionArn    = "arn:aws:codestar-connections:us-east-1:563539093289:connection/804203dc-6978-4a51-a29e-7aa51c170be8"
        FullRepositoryId = "pozniakoo/trening"
        BranchName       = "prod"
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
        ApplicationName = "CodeDeployProdApp"
        DeploymentGroupName = "CDDeployGroupForProd"
      }
    }
  }
}
