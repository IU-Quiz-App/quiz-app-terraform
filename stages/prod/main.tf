terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83.1"
    }
  }
  backend "s3" {
    bucket         = "do-not-delete-iu-quiz-tf-state-prod"
    key            = "terraform.state"
    region         = "eu-central-1"
    dynamodb_table = "do-not-delete-iu-quiz-terraform-state-lock-prod"
  }

  required_version = ">= 1.5.7"
}

provider "aws" {
  region              = "eu-central-1"
  allowed_account_ids = ["ACCOUNT_ID"]
}

module "main" {
  source = "../../modules/main"
  stage  = "prod"
}
