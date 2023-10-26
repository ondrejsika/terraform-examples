resource "aws_secretsmanager_secret" "env" {
  for_each = var.secrets

  name = "${var.name}/${each.key}"
}

resource "aws_secretsmanager_secret_version" "env" {
  for_each = var.secrets

  secret_id     = aws_secretsmanager_secret.env[each.key].id
  secret_string = each.value
}
