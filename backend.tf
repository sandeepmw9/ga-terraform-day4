terraform {
  #   backend "s3" {
  #     bucket = "value"
  #     key = "value"
  #     region = "value"
  #     dynamodb_table = "value"
  #   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
}