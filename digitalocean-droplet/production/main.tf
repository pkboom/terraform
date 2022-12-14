terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "api_token" {}

provider "digitalocean" {
  token = var.api_token
}

data "digitalocean_image" "this" {
  name = "${var.infra_name}-web"
}

resource "digitalocean_droplet" "this" {
  image  = data.digitalocean_image.this.id
  name   = "${var.infra_name}-${var.infra_env}-${var.infra_type}"
  region = "tor1"
  size   = "s-1vcpu-1gb"
  # tags may contain lowercase letters, numbers, colons, dashes, and underscores; 
  # there is a limit of 255 characters per tag
  tags = [
    var.infra_name,
    var.infra_env,
    var.infra_type,
  ]
}
