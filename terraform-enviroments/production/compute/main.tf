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

# New data sources used:
data "aws_vpc" "vpc" {
  tags = {
    Name        = "cloudcasts-${var.infra_env}-vpc"
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name        = "cloudcasts-${var.infra_env}-vpc"
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
    Role        = "public"
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name        = "cloudcasts-${var.infra_env}-vpc"
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
    Role        = "private"
  }
}

data "aws_security_groups" "public_sg" {
  tags = {
    Name        = "cloudcasts-${var.infra_env}-public-sg"
    Role        = "public"
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

data "aws_security_groups" "private_sg" {
  tags = {
    Name        = "cloudcasts-${var.infra_env}-private-sg"
    Role        = "private"
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

module "ec2_app" {
  source = "../../modules/ec2"

  infra_env     = var.infra_env
  infra_role    = "web"
  instance_size = "t3.small"
  instance_ami  = data.aws_ami.app.id
  # instance_root_device_size = 12
  subnets         = data.aws_subnets.public_subnets.ids
  security_groups = data.aws_security_groups.public_sg.ids
  tags = {
    Name = "cloudcasts-${var.infra_env}-web"
  }
  create_eip = true
}

module "ec2_worker" {
  source = "../../modules/ec2"

  infra_env                 = var.infra_env
  infra_role                = "worker"
  instance_size             = "t3.large"
  instance_ami              = data.aws_ami.app.id
  instance_root_device_size = 20
  subnets                   = data.aws_subnets.private_subnets.ids
  security_groups           = data.aws_security_groups.private_sg.ids
  tags = {
    Name = "cloudcasts-${var.infra_env}-worker"
  }
  create_eip = false
}
