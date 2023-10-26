resource "aws_ecs_task_definition" "this" {
  family                   = "app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name  = "main"
      image = var.image
      environment = [
        for k, v in var.environment : {
          name  = k
          value = v
        }
      ]
      secrets = [
        for k, v in var.secrets : {
          name      = k
          valueFrom = aws_secretsmanager_secret.env[k].arn
        }
      ]
      portMappings = [{
        containerPort = 80
      }]
    },
  ])
}

resource "aws_lb_target_group" "this" {
  vpc_id      = var.vpc_id
  name        = var.name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.laod_balancer_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [var.domain_name]
    }
  }
}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "main"
    container_port   = 80
  }
}

resource "aws_security_group" "this" {
  name   = var.name
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "this" {
  name    = var.domain_name
  zone_id = var.zone_id
  type    = "A"

  alias {
    name                   = var.laod_balancer_dns_name
    zone_id                = var.laod_balancer_zone_id
    evaluate_target_health = true
  }
}

output "domain_name" {
  value = var.domain_name
}
