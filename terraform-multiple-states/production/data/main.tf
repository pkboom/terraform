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

variable db_user {
  type = string
  description = "the database user"
}
 
variable db_pass {
  type = string
  description = "the database password"
}

# New data sources used:
data "aws_vpc" "vpc" {
  tags = {
    Name        = "cloudcasts-${var.infra_env}-vpc"
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

data "aws_subnets" "database_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name        = "cloudcasts-${var.infra_env}-vpc"
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
    Role        = "database"
  }
}

module "database" {
    source = "../../modules/rds"
    
    infra_env = var.infra_env
    instance_type = "db.t3.medium"
    subnets = data.aws_subnet_ids.database_subnets.ids
    vpc_id = data.aws_vpc.vpc.id
    master_username = var.db_user
    master_password = var.db_pass
}