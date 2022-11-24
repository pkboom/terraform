variable "infra_env" {
  type        = string
  description = "infrastructure environment"
}

variable "vpc_cidr" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_numbers" {
  type = map(number)

  description = "Map of AZ(Availability Zone) to a number that should be used for public subnets"

  default = {
    "us-east-2a" = 0
    "us-east-2b" = 1
    "us-east-2c" = 2
  }
}

variable "private_subnet_numbers" {
  type = map(number)

  description = "Map of AZ(Availability Zone) to a number that should be used for private subnets"

  default = {
    "us-east-2a" = 4
    "us-east-2b" = 5
    "us-east-2c" = 6
  }
}

output "security_group_public" {
  value = aws_security_group.public.id
}

output "security_group_private" {
  value = aws_security_group.private.id
}
