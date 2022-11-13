terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "cloudcasts-terraform-keunbae"
    key            = "cloudcasts/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "cloudcasts-terraform-keunbae"
    profile        = "cloudcasts"
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
  source = "./modules/ec2"

  infra_env     = var.infra_env
  infra_role    = "app"
  instance_size = "t3.small"
  instance_ami  = data.aws_ami.app.id
  # instance_root_device_size = 12 # Optional
}

module "ec2_worker" {
  source = "./modules/ec2"

  infra_env                 = var.infra_env
  infra_role                = "worker"
  instance_size             = "t3.large"
  instance_ami              = data.aws_ami.app.id
  instance_root_device_size = 50
}

module "vpc" {
  source = "./modules/vpc"

  infra_env = var.infra_env
  vpc_cidr  = "10.0.0.0/17"
}
