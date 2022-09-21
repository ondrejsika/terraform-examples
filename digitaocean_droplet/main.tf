locals {
  name   = "example"
  image  = "debian-11-x64"
  region = "fra1"
  size   = "s-2vcpu-4gb"
}

resource "digitalocean_droplet" "main" {
  image     = local.image
  name      = local.name
  region    = local.region
  size      = local.size
  user_data = <<EOF
#cloud-config
ssh_pwauth: yes
password: asdfasdf2020
chpasswd:
  expire: false
write_files:
- path: /root/.ssh/authorized_keys
  permissions: "0600"
  owner: root:root
  content: |
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCslNKgLyoOrGDerz9pA4a4Mc+EquVzX52AkJZz+ecFCYZ4XQjcg2BK1P9xYfWzzl33fHow6pV/C6QC3Fgjw7txUeH7iQ5FjRVIlxiltfYJH4RvvtXcjqjk8uVDhEcw7bINVKVIS856Qn9jPwnHIhJtRJe9emE7YsJRmNSOtggYk/MaV2Ayx+9mcYnA/9SBy45FPHjMlxntoOkKqBThWE7Tjym44UNf44G8fd+kmNYzGw9T5IKpH1E1wMR+32QJBobX6d7k39jJe8lgHdsUYMbeJOFPKgbWlnx9VbkZh+seMSjhroTgniHjUl8wBFgw0YnhJ/90MgJJL4BToxu9PVnH
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGMpvuTogTt+O5PcyTW+H9d0Ir35+Fcz0L601UXodD7w6nfB8xp+QoVrzYLDgSNT5xeoLW+JayI09xZnlqeCymZtXcbjx1g/h1BwZycvwXiwDaG7IJNg5baFjfVKWuQ7AU344TNrVaLQRBe6X7ndZ19K8bhX76TTtZGUrX4Jy+dEmPKEVsHOy7+NR0w9X8GTfy61xzsAdUMjfpUboS6FHNoiyE97qC6NPNTDXTWfLGr2s80MpqLlmxrAyTndrLkUXH7H7xbVODK2FfDzVOcNEUCzAlYBwOGdcQzoXzFHC/sPflOLn2Ozcr0b5XAj58AV2dI4oTFGuwiWv+D1KPUj1vzgH2oXyAXO9MK9n6Yvb/ID2GpHOvXGY2qPPxO1abpvg5gDLuW5TZC9zE4lKIaFIlNBFLbiXXNWUGba2oPjLHqPC3EIwfjtPiytrvb8trCabEjtgOmYbNC4XJgWbP8eETuWgykio67Av9QFeQBjn4ZiXMFcya3Yu9UbMy3kfHeGlWoKuXPJca8AQqRfuC/xknQKTGIwupV6+Ett8CN4Vju3mO/pfzxnHvOVW3b2Kg1rgeFWd0rD+aR5EUWt2/upvlAXlE8XdIwCRG7Bww7KTSH+jZxCoaOetLesWq1BT494wWzVQufYUeRXlx3S0a2t3IzIV9aVCKPCw1PfbotxwN/Q==
runcmd:
  - |
    rm -rf /etc/update-motd.d/99-one-click
    apt update
    apt install curl sudo git
    # systemctl stop ufw
    # systemctl disable ufw
    curl -fsSL https://ins.oxs.cz/slu-linux-amd64.sh | sudo sh
EOF
}

output "ip" {
  value = digitalocean_droplet.main.ipv4_address
}
