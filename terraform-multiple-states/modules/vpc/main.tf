# The community VPC module creates an IGW, NAT Gateway for us.
# This module intelligently creates route tables for public vs private subnets as well.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "cloudcasts-${var.infra_env}-vpc"
  cidr = var.vpc_cidr

  azs = var.azs

  # Single NAT Gateway, see docs linked above
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  database_subnets = var.database_subnets

  tags = {
    Name        = "cloudcasts-${var.infra_env}-vpc"
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }

  private_subnet_tags = {
    Role = "private"
  }

  public_subnet_tags = {
    Role = "public"
  }

  database_subnet_tags = {
    Role = "database"
  }
}


