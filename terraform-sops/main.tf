terraform {
  required_providers {
    sops = {
      source = "carlpett/sops"
      version = "~> 0.5"
    }
  }
}

data "sops_file" "secret" {
  source_file = "secret.enc.json"
}

output "root-value-password" {
  value = data.sops_file.secret.data["password"]
  sensitive = true
}

output "mapped-nested-value" {
  value = data.sops_file.secret.data["db.password"]
  sensitive = true
}

output "nested-json-value" {
  value = jsondecode(data.sops_file.secret.raw).db.password
  sensitive = true
}
