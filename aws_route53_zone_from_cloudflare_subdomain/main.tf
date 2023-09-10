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
  region     = "eu-central-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

variable "cloudflare_email" {}
variable "cloudflare_api_key" {}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

variable "domain" {}
variable "subdomain" {}

resource "aws_route53_zone" "main" {
  name = "${var.subdomain}.${var.domain}"
}

data "cloudflare_zone" "main" {
  name = var.domain
}

resource "cloudflare_record" "ns" {
  count = 4

  zone_id = data.cloudflare_zone.main.id
  name    = var.subdomain
  value   = aws_route53_zone.main.name_servers[count.index]
  type    = "NS"
  ttl     = 1
}
