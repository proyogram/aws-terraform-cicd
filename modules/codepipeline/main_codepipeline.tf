locals {
  cicd_terraform_codebuild_repository_uri = "public.ecr.aws/hashicorp/terraform:1.4.0"

  cicd_terraform_pipelines = {
    region = "ap-northeast-1"
    env    = "dev"
  }
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.prefix}-codepipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "${var.prefix}-source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.full_repository_id
        BranchName       = var.branch_name
      }
    }
  }

  stage {
    name = "Plan"
    action {
      name             = "${var.prefix}-build-plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output_plan"]
      version          = "1"

      configuration = {
        ProjectName   = aws_codebuild_project.cicd_terraform_plan.name
        PrimarySource = "source_output"
      }
    }
  }

  stage {
    name = "Approval"
    action {
      name            = "${var.prefix}-approval"
      category        = "Approval"
      owner           = "AWS"
      provider        = "Manual"
      version         = "1"
      input_artifacts = []
      configuration = {
        CustomData = "Terraform apply for GitHub Repository '${var.full_repository_id}'."
      }
    }
  }

  stage {
    name = "Apply"
    action {
      name            = "${var.prefix}-apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["build_output_plan"]
      version         = "1"

      configuration = {
        ProjectName   = aws_codebuild_project.cicd_terraform_apply.name
        PrimarySource = "terraform_sources"
      }
    }
  }
}

resource "aws_codestarconnections_connection" "github" {
  name          = "${var.prefix}-git-connection"
  provider_type = "GitHub"
}


resource "aws_codebuild_project" "cicd_terraform_plan" {
  name          = "${var.prefix}-plan-project"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 90

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "arn:aws:s3:::${aws_s3_bucket.codepipeline_bucket.id}/buildspec/buildspec_plan.yml"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = local.cicd_terraform_codebuild_repository_uri
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = false
    environment_variable {
      name  = "AWS_DEFULT_REGION"
      value = data.aws_region.current.name
    }
  }
}

resource "aws_codebuild_project" "cicd_terraform_apply" {
  name          = "${var.prefix}-apply-project"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 90

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "arn:aws:s3:::${aws_s3_bucket.codepipeline_bucket.id}/buildspec/buildspec_apply.yml"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = local.cicd_terraform_codebuild_repository_uri
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = false
    environment_variable {
      name  = "AWS_DEFULT_REGION"
      value = data.aws_region.current.name
    }
  }
}
