terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    region = "us-east-2"
    # dynamodb_table = "cloudcasts-terraform-keunbae"
    profile = "cloudcasts"
  }
}

provider "aws" {
  profile = "cloudcasts"
  region  = "us-east-2"
}

variable "infra_env" {
  type        = string
  description = "infrastructure environment"
  default     = "production"
}

variable "default_region" {
  type        = string
  description = "the region this infrastructure is in"
  default     = "us-east-2"
}

locals {
  cidr_subnets = cidrsubnets("10.0.0.0/17", 4, 4, 4, 4, 4, 4, 4, 4, 4)
}

module "vpc" {
  source = "../../modules/vpc"

  infra_env = var.infra_env
  # For later use(peer comminucations between subnets), we use 10.0.0.0/17 instead of 10.0.0.0/16
  vpc_cidr         = "10.0.0.0/17"
  azs              = ["us-east-2a", "us-east-2b", "us-east-2c"]
  public_subnets   = slice(local.cidr_subnets, 0, 3)
  private_subnets  = slice(local.cidr_subnets, 3, 6)
  database_subnets = slice(local.cidr_subnets, 6, 9)
}

