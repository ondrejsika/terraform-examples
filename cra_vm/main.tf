variable "vcd_user" {}
variable "vcd_password" {}
variable "vcd_org" {}
variable "vcd_vdc" {}
variable "vcd_url" {}

variable "vcd_catalog_org" {}
variable "vcd_catalog_name" {}

variable "vcd_catalog_vapp_template_org" {}
variable "vcd_catalog_vapp_template_name" {}

variable "vapp_name" {}
variable "org_network_name" {}

variable "ip" {}

provider "vcd" {
  user                 = var.vcd_user
  password             = var.vcd_password
  org                  = var.vcd_org
  vdc                  = var.vcd_vdc
  url                  = var.vcd_url
  allow_unverified_ssl = false
}

data "vcd_catalog" "default" {
  org  = var.vcd_catalog_org
  name = var.vcd_catalog_name
}

data "vcd_catalog_vapp_template" "debian10" {
  catalog_id = data.vcd_catalog.default.id
  org        = var.vcd_catalog_vapp_template_org
  name       = var.vcd_catalog_vapp_template_name
}

data "vcd_vapp_org_network" "default" {
  vapp_name        = var.vapp_name
  org_network_name = var.org_network_name
}

resource "vcd_vapp_vm" "demo" {
  vapp_name     = var.vapp_name
  name          = "demo"
  computer_name = "demo"
  memory        = 1024
  cpus          = 1

  power_on         = "true"
  vapp_template_id = data.vcd_catalog_vapp_template.debian10.id

  network {
    type               = "org"
    name               = data.vcd_vapp_org_network.default.org_network_name
    ip_allocation_mode = "MANUAL"
    ip                 = var.ip
    is_primary         = true
    adapter_type       = "VMXNET3"
  }

  customization {
    enabled                             = true
    force                               = false
    allow_local_admin_password          = false
    auto_generate_password              = true
    must_change_password_on_first_login = false
  }

  guest_properties = {
    "user-data" = base64encode(<<EOF
#cloud-config
system_info:
  default_user:
    name: root
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCslNKgLyoOrGDerz9pA4a4Mc+EquVzX52AkJZz+ecFCYZ4XQjcg2BK1P9xYfWzzl33fHow6pV/C6QC3Fgjw7txUeH7iQ5FjRVIlxiltfYJH4RvvtXcjqjk8uVDhEcw7bINVKVIS856Qn9jPwnHIhJtRJe9emE7YsJRmNSOtggYk/MaV2Ayx+9mcYnA/9SBy45FPHjMlxntoOkKqBThWE7Tjym44UNf44G8fd+kmNYzGw9T5IKpH1E1wMR+32QJBobX6d7k39jJe8lgHdsUYMbeJOFPKgbWlnx9VbkZh+seMSjhroTgniHjUl8wBFgw0YnhJ/90MgJJL4BToxu9PVnH ondrejsika
EOF
    )
  }
}
