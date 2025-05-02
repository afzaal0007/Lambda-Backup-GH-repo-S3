terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Define the provider for AWS
provider "aws" {
  region = var.aws_region
}


terraform {
  backend "s3" {
    bucket         = "github-backup-bucket-afzaal0002"
    key            = "github-backup/terraform.tfstate"
    dynamodb_table = "terraform-lock-table"
    region         = "eu-west-1"
    encrypt        = true
  }
}

