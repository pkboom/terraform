terraform {
  # define provider
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # https://cloudcasts.io/course/terraform/local-and-remote-state
  # https://cloudcasts.io/course/terraform/state-locking-with-dynamodb
  # https://developer.hashicorp.com/terraform/language/settings/backends/configuration
  # You can't use variables in the `backend` configuration
  backend "s3" {
    bucket         = "cloudcasts-terraform-keunbae"
    key            = "cloudcasts/terraform.tfstate" // location inside the bucket
    region         = "us-east-2"
    profile        = "cloudcasts"
    dynamodb_table = "cloudcasts-terraform-keunbae"
  }
}

# configure provider
provider "aws" {
  region  = var.default_region
  profile = "cloudcasts"
}

# define data source
data "aws_ami" "ubuntu" {
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

# define resource instance(ec2)
resource "aws_instance" "cloudcasts_web" {
  # if ami is different from the existing one, it will
  # replace an existing one with a new one.
  ami           = "ami-0f924dc71d44d23e2" # data.aws_ami.ubuntu.id
  instance_type = var.instance_size

  root_block_device {
    volume_size = 8 # GB
    volume_type = "gp3"
  }

  # lifecycle can be applied to all resources.
  # https://www.terraform.io/language/meta-arguments/lifecycle
  # lifecycle {
  #   create_before_destroy = true
  # }

  # Ignore changes to tags, e.g. because a management agent
  # updates these based on some ruleset managed elsewhere.
  # In other words, when tags change outside of terraform,
  # we don't want to replace the resource.
  # usecase: rds is updated outside of terraform
  # and you use this to prevent terraform from replacing the resource.
  # lifecycle {
  #   ignore_changes = [
  #     tags,
  #   ]
  # }

  tags = {
    Name        = "cloudcasts_${var.infra_env}_web"
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

# define resource elastic ip
resource "aws_eip" "app_eip" {
  # inside vpc
  vpc = true

  # you don't want to remove an ip address accidentally
  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = {
    Name        = "cloudcasts_${var.infra_env}_web_address"
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

# We want to use aws_eip_association
# to decouple instances and eip.
resource "aws_eip_association" "app_eip_assoc" {
  allocation_id = aws_eip.app_eip.id
  instance_id   = aws_instance.cloudcasts_web.id
}
