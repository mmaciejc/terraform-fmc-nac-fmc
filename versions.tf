terraform {
  #required_version = ">= 1.3.0"

  required_providers {
    fmc = {
      source = "netascode/fmc"
      version = "6.6.3"
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

#provider "fmc" {
#  username = "terraform_restapi"
#  password = "terraform_restapi123"
#  url      = "https://10.52.13.145:12443/"
#}

provider "fmc" {
  username = "admin"
  password = "SecretPass123!"
  url      = "https://10.62.158.200/"
}
