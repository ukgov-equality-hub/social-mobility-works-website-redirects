
terraform {
  required_version = ">= 1.6.2"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.23"
    }
  }

  backend "s3" {
    region = "eu-west-2"
  }
}

provider "aws" {
  region = var.aws_region // no alias is provided so will be used as default

  default_tags {
    tags = {
      Service = var.service_name
    }
  }
}

provider "aws" { // This us-east-1 provider is needed for CloudFront
  region = "us-east-1"
  alias = "us-east-1"

  default_tags {
    tags = {
      Service = var.service_name
    }
  }
}
