# The community VPC module creates an IGW, NAT Gateway, Route tables for us.
# This module intelligently creates route tables for public vs private subnets as well.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "cloudcasts-${var.infra_env}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  # Single NAT Gateway, see docs linked above
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Name        = "cloudcasts-${var.infra_env}-vpc"
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}


