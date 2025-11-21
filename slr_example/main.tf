resource "slr_hello" "default" {}

resource "slr_hello" "doggos" {
  for_each = toset([
    "Dela",
    "Nela",
  ])

  name = each.key
}

output "hello_default" {
  value = slr_hello.default.message
}

output "hello_doggos" {
  value = { for k, v in slr_hello.doggos : k => v.message }
}
