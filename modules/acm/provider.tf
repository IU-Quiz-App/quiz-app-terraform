provider "aws" {
  alias               = "us-east-1"
  region              = "us-east-1"
  allowed_account_ids = ["739275480216"]
  default_tags {
    tags = {
      Environment          = var.stage
      Created_by_Terraform = "True"
    }
  }
}
