terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = {
      version = "~> 4.12.1"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {
}

resource "random_pet" "e2e" {
}

resource "random_password" "windows_admin_password" {
  length           = 20
  special          = true
  override_special = "_%@"
}

locals {
  random_name = "${var.name}-${random_pet.e2e.id}"
}

# Generates keys to use for provisioning and access
module "keys" {
  name    = local.random_name
  path    = "${path.root}/keys"
  source  = "mitchellh/dynamic-keys/aws"
  version = "v2.0.0"
}
