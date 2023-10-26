variable "name" {}
variable "ecs_cluster_id" {}
variable "execution_role_arn" {}
variable "vpc_id" {}
variable "subnets" {}
variable "zone_id" {}
variable "domain_name" {}
variable "laod_balancer_dns_name" {}
variable "laod_balancer_zone_id" {}
variable "laod_balancer_listener_arn" {}
variable "image" {}
variable "secrets" {
  default = {}
}
variable "environment" {
  default = {}
}
