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

data "aws_ami" "app" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical official
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

variable "instance_size" {
  type        = string
  description = "ec2 web server size"
  default     = "t3.small"
}

module "ec2_app" {
  source = "../modules/ec2"

  infra_env     = var.infra_env
  infra_role    = "app"
  instance_size = "t3.small"
  instance_ami  = data.aws_ami.app.id
  # instance_root_device_size = 12 # optional
  subnets         = module.vpc.vpc_public_subnets
  security_groups = [module.vpc.security_group_public]
  tags = {
    Name = "cloudcasts-${var.infra_env}-web"
  }
  create_eip = true
}

module "ec2_worker" {
  source = "../modules/ec2"

  infra_env     = var.infra_env
  infra_role    = "worker"
  instance_size = "t3.small"
  instance_ami  = data.aws_ami.app.id
  # instance_root_device_size = 20 
  subnets         = module.vpc.vpc_private_subnets
  security_groups = [module.vpc.security_group_private]
  tags = {
    Name = "cloudcasts-${var.infra_env}-worker"
  }
  create_eip = false
}

module "vpc" {
  source = "../modules/vpc"

  infra_env = var.infra_env
  # For later use(peer comminucations between subnets), we use 10.0.0.0/17 instead of 10.0.0.0/16
  vpc_cidr = "10.0.0.0/17"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  public_subnets  = slice(cidrsubnets("10.0.0.0/17", 4, 4, 4, 4, 4, 4), 0, 3)
  private_subnets = slice(cidrsubnets("10.0.0.0/17", 4, 4, 4, 4, 4, 4), 3, 6)
}

