resource "aws_ecs_cluster" "this" {
  name = var.name
}

output "id" {
  value = aws_ecs_cluster.this.id
}

output "execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}
