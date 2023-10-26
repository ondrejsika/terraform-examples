terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "eu-central-1"
}

variable "cloudflare_api_token" {}
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
