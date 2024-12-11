terraform {
  #required_version = ">= 1.3.0"

  required_providers {
    fmc = {
      source = "netascode/fmc"
      version = "0.0.1"
    }
    utils = {
      source  = "netascode/utils"
      version = ">= 0.2.6"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.2"
    }
  }
}

