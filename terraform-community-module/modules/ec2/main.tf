resource "random_shuffle" "subnets" {
  input        = var.subnets
  result_count = 1
}


# https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0"

  name = "cloudcasts-${var.infra_env}"

  ami                    = var.instance_ami
  instance_type          = var.instance_size
  vpc_security_group_ids = var.security_groups
  subnet_id              = random_shuffle.subnets.result[0]

  root_block_device = [{
    volume_size = var.instance_root_device_size
    volume_type = "gp3"
  }]

  tags = merge(
    {
      Name        = "cloudcasts-${var.infra_env}"
      Role        = var.infra_role
      Project     = "cloudcasts.io"
      Environment = var.infra_env
      ManagedBy   = "terraform"
    },
    var.tags
  )
}


resource "aws_eip" "cloudcasts_addr" {
  # Create the number of `count` of EIPs
  count = (var.create_eip) ? 1 : 0

  # inside vpc
  vpc = true

  lifecycle {
    # prevent_destroy = true
  }

  tags = {
    Name        = "cloudcasts-${var.infra_env}-web-address"
    Role        = var.infra_role
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_eip_association" "eip_assoc" {
  count = (var.create_eip) ? 1 : 0

  instance_id   = module.ec2-instance.id
  allocation_id = aws_eip.cloudcasts_addr[0].id
}
