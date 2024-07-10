terraform {
  #required_version = ">= 1.3.0"

  required_providers {
    fmc = {
      source = "netascode/fmc"
      version = "6.6.1"
    }
    utils = {
      source  = "netascode/utils"
      version = ">= 0.2.6"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.3.0"
    }
  }
}

provider "fmc" {
  username = "admin"
  password = var.fmc_password
  url      = "https://10.62.158.200"
}