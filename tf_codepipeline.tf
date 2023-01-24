resource "aws_s3_bucket" "cpl_react_frontend" {
  provider      = aws.east1
  bucket        = "cpl-bucket-993058117004"
  force_destroy = false

  tags = {
    Provisioner = var.provisioner
    Provisioner = var.environment
  }
}

resource "aws_s3_bucket_acl" "cpl_bucket_acl" {
  bucket = aws_s3_bucket.cpl_react_frontend.id
  acl    = "private"
}

resource "aws_codepipeline" "cpl" {
  name     = "cpl-react-frontend"
  role_arn = aws_iam_role.cpl_role.arn

  artifact_store {
    location = aws_s3_bucket.cpl_react_frontend.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        PollForSourceChanges = true
        RepositoryName       = aws_codecommit_repository.cc_react_frontend.repository_name
        BranchName           = var.branchName
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.cb_react_frontend.name
      }
    }
  }

  tags = {
    Provisioner = var.provisioner
    Provisioner = var.environment
  }
}


resource "aws_iam_role" "cpl_role" {
  name = "cpl-assume-role-tf"

  assume_role_policy = file("./policies/cpl_assume_role.json")

  tags = {
    Provisioner = var.provisioner
    Provisioner = var.environment
  }
}

resource "aws_iam_role_policy" "cpl_policy" {
  name = "cpl_policy"
  role = aws_iam_role.cpl_role.name

  policy = file("./policies/cpl_service.json")
}
