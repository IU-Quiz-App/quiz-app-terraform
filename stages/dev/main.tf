terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83.1"
    }
  }
  backend "s3" {
    bucket         = "do-not-delete-iu-quiz-tf-state-dev"
    key            = "terraform.state"
    region         = "eu-central-1"
    dynamodb_table = "do-not-delete-iu-quiz-terraform-state-lock-dev"
  }

  required_version = ">= 1.5.7"
}

provider "aws" {
  region              = "eu-central-1"
  allowed_account_ids = ["739275480216"]
}

module "main" {
  source = "../../modules/main"
  stage  = "dev"
  domain = "iu-quiz.de"
}
