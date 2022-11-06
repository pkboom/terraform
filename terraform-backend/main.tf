terraform {
  # backend "s3" {
  #   bucket         = "terraform-state-keunbae"
  #   key            = "global/s3/terraform.tfstate"
  #   region         = "us-east-2"
  #   dynamodb_table = "terraform-locks-keunbae"
  #   encrypt        = true
  #   profile        = "cloudcasts"
  # }
}

provider "aws" {
  region  = "us-east-2"
  profile = "cloudcasts"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-keunbae"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    # prevent_destroy = true
  }
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# block all public access to the S3 bucket
# S3 buckets are private by default
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-keunbae"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# output

# Run `terraform apply` to see the Amazon Resource Name (ARN) of your S3 bucket and
# the name of your DynamoDB table.
output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}

# Outputs example
# dynamodb_table_name = "terraform-locks-keunbae"
# s3_bucket_arn       = "arn:aws:s3:::terraform-state-keunbae"
