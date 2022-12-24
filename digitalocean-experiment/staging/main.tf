terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.api_token
}

variable "api_token" {}

data "digitalocean_image" "this" {
  name = "experiment-web"
}

resource "digitalocean_droplet" "web" {
  image  = data.digitalocean_image.this.id
  name   = "${var.infra_name}-${var.infra_env}-web"
  region = "tor1"
  size   = "s-1vcpu-1gb"
  tags = {
    Project     = "experiment.com"
    Environment = var.infra_env
    Type        = "web"
    ManagedBy   = "terraform"
  }
}
