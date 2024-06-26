terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state"
    key    = "terraform.tfstate"
    region = var.region
    encrypt = true
    dynamodb_table = "tfstate-lock"
  }

}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.region
}