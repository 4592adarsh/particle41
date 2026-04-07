terraform {
  #  backend "s3" {
  #    bucket         = "particle41-assignment"
  #    key            = "development/terraform.tfstate"
  #    region         = "us-east-1"
  #    encrypt        = true
  #    dynamodb_table = "particle41-assignment-lock"
  #  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
