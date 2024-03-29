terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.21.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.3"
    }
  }
}
