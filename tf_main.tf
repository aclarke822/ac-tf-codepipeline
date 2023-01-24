terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.47.0"
    }
  }
}

provider "aws" {
  alias  = "east1"
  region = "us-east-1"
}

data "aws_region" "region" {
  provider = aws.east1
}

terraform {
  backend "s3" {
    bucket         = "ac-tf-rs-993058117004"
    key            = "ac-tf-codepipeline"
    region         = "us-east-1"
    dynamodb_table = "ac-tf-rs-locks-993058117004"
  }
}
