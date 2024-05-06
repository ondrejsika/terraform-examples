terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
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
