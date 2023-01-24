resource "aws_iam_role" "codebuild_lamda" {
  name               = "codebuild-lamda-tf"
  assume_role_policy = file("./policies/cb_assume_role.json")
  managed_policy_arns = [
  "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForLambda"]

  tags = {
    Provisioner = var.provisioner
    Provisioner = var.environment
  }
}

data "template_file" "codebuild_lamda_policy" {
  template = file("./policies/cb_lamda.json")
  vars = {
    arn_s3_pipeline_bucket    = aws_s3_bucket.cpl_react_frontend.arn
    arn_codecommit_repository = aws_codecommit_repository.cc_react_frontend.arn
    arn_codepipeline_bucket = aws_s3_bucket.cpl_react_frontend.arn
  }
}

resource "aws_iam_role_policy" "codebuild_lamda" {
  name = "codebuild-lamda-tf"
  role = aws_iam_role.codebuild_lamda.name

  policy = data.template_file.codebuild_lamda_policy.rendered
}

resource "aws_codebuild_project" "cb_react_frontend" {
  badge_enabled  = false
  name           = "cb-react-frontend"
  description    = "cb-react-frontend Build Project (React)"
  build_timeout  = "5"
  queued_timeout = "5"

  service_role = aws_iam_role.codebuild_lamda.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    environment_variable {
      name  = "REPOSITORY"
      value = aws_codeartifact_repository.car_ac_tf_codepipeline.repository
    }
    environment_variable {
      name  = "DOMAIN"
      value = aws_codeartifact_domain.cad_ac_tf_codepipeline.domain
    }
    environment_variable {
      name  = "DOMAIN_OWNER"
      value = aws_codeartifact_repository.car_ac_tf_codepipeline.domain_owner
    }
    environment_variable {
      name  = "REGION"
      value = data.aws_region.region.name
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      status = "DISABLED"
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.cc_react_frontend.repository_name
    git_clone_depth = 1
  }

  source_version         = "main"
  concurrent_build_limit = 1

  tags = {
    Provisioner = var.provisioner
    Provisioner = var.environment
  }
}
