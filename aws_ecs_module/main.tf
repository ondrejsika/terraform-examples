locals {
  domain    = "sikademo.com"
  subdomain = "aws-ecs-example"
}

resource "aws_route53_zone" "main" {
  name = "${local.subdomain}.${local.domain}"
}

data "cloudflare_zone" "root" {
  name = local.domain
}

resource "cloudflare_record" "ns" {
  count = 4

  zone_id = data.cloudflare_zone.root.id
  name    = local.subdomain
  value   = aws_route53_zone.main.name_servers[count.index]
  type    = "NS"
}

module "vpc" {
  source = "./modules/aws_vpc"

  name       = "aws-ecs-example"
  cidr_block = "10.250.0.0/16"
  subnets = {
    "10.250.1.0/24" = {
      az = "eu-central-1a"
    }
    "10.250.2.0/24" = {
      az = "eu-central-1b"
    }
  }
}

module "alb" {
  source = "./modules/aws_alb"

  name        = "aws-ecs-example-alb"
  zone_id     = aws_route53_zone.main.zone_id
  domain_name = "${local.subdomain}.${local.domain}"
  subject_alternative_names = [
    "ahoj.${local.subdomain}.${local.domain}",
  ]
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.subnet_ids
}

module "ecs_cluster" {
  source = "./modules/aws_ecs_cluster"

  name = "aws-ecs-example-ecs"
}

module "ecs_service" {
  source = "./modules/aws_ecs_service"

  name                       = "hello"
  ecs_cluster_id             = module.ecs_cluster.id
  execution_role_arn         = module.ecs_cluster.execution_role_arn
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.subnet_ids
  zone_id                    = aws_route53_zone.main.zone_id
  domain_name                = "${local.subdomain}.${local.domain}"
  laod_balancer_listener_arn = module.alb.laod_balancer_listener_arn
  laod_balancer_dns_name     = module.alb.dns_name
  laod_balancer_zone_id      = module.alb.zone_id
  image                      = "sikalabs/hello-world-server"
  environment = {
    PORT = "80"
  }
  secrets = {
    TEXT = "Hello from ECS"
  }
}

module "ecs_service_ahoj" {
  source = "./modules/aws_ecs_service"

  name                       = "ahoj"
  ecs_cluster_id             = module.ecs_cluster.id
  execution_role_arn         = module.ecs_cluster.execution_role_arn
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.subnet_ids
  zone_id                    = aws_route53_zone.main.zone_id
  domain_name                = "ahoj.${local.subdomain}.${local.domain}"
  laod_balancer_listener_arn = module.alb.laod_balancer_listener_arn
  laod_balancer_dns_name     = module.alb.dns_name
  laod_balancer_zone_id      = module.alb.zone_id
  image                      = "sikalabs/hello-world-server"
  environment = {
    PORT = "80"
  }
  secrets = {
    TEXT = "Ahoj z ECS"
  }
}

output "go_to_hello" {
  value = "https://${module.ecs_service.domain_name}"
}

output "go_to_ahoj" {
  value = "https://${module.ecs_service_ahoj.domain_name}"
}
