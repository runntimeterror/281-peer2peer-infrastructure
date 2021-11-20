resource "aws_elasticache_cluster" "moochat_redis_cluster" {
  cluster_id           = "moo-chat-redis"
  availability_zone        = "us-east-1a"
  az_mode                  = "single-az"
  port              = 6379
  engine                   = "redis"
  node_type                = "cache.t2.micro"
  num_cache_nodes          = 1
  parameter_group_name     = "default.redis6.x"
  security_group_ids       = [
    "sg-0b03f389b81b18623",
    "sg-0d3fee5cb05cef4b4",
    resource.aws_security_group.sg_moochat_ecs_tasks.id,
  ]
  snapshot_retention_limit = 0
  snapshot_window          = "05:00-06:00"
  subnet_group_name        = "default"
  tags                     = {}
  tags_all                 = {}
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}

resource "aws_ecr_repository" "moochat_ecr_repo" {
  name = "${terraform.workspace}-moochat-socket-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_security_group" "sg_moochat_loadbalancer" {
  name        = "${terraform.workspace}-securitygroup-moochatlb"
  description = "controls access to the Application Load Balancer (ALB)"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_moochat_ecs_tasks" {
  name        = "${terraform.workspace}-securitygroup-moochat-ecs"
  description = "allow inbound access from the ALB only"

  ingress {
    protocol        = "tcp"
    from_port       = 8000
    to_port         = 8000
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.sg_moochat_loadbalancer.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "lb_moochat" {
  name               = "${terraform.workspace}-loadbalancer-moochat"
  subnets            = data.aws_subnet_ids.default.ids
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_moochat_loadbalancer.id]

  tags = {
    Environment = "${terraform.workspace}"
    Application = "moochat-socket-service"
  }
}

resource "aws_lb_listener" "https_forward" {
  load_balancer_arn = aws_lb.lb_moochat.arn
  port              = 80
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.moochat_alb_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group_moochat.arn
  }
}

data "aws_acm_certificate" "moochat_alb_certificate" {
  domain = "socket.moochat.awesomepossum.dev"
}

resource "aws_lb_target_group" "lb_target_group_moochat" {
  name        = "${terraform.workspace}-lbtargetgroup-moochat"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "90"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

data "aws_iam_policy_document" "moochat_ecs_iam_policy" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "moochat_ecs_task_execution_role" {
  name               = "${terraform.workspace}-moochat-execution-role"
  assume_role_policy = data.aws_iam_policy_document.moochat_ecs_iam_policy.json
}

resource "aws_iam_role_policy_attachment" "moochat_ecs_iam_policy_attachment" {
  role       = aws_iam_role.moochat_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "template_file" "moochat_task_definition" {
  template = file("./modules/socket_service/socket_service.json.tpl")
  vars = {
    aws_ecr_repository = resource.aws_ecr_repository.moochat_ecr_repo.repository_url
    tag                = "latest"
    app_port           = 80
  }
}

resource "aws_ecs_task_definition" "moochat_service_task" {
  family                   = "${terraform.workspace}-moochat"
  network_mode             = "awsvpc"
  execution_role_arn       = resource.aws_iam_role.moochat_ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.moochat_task_definition.rendered
  tags = {
    Environment = "${terraform.workspace}"
    Application = "moochat-socket-service"
  }
}

resource "aws_ecs_cluster" "moochat_ecs_cluster" {
  name = "${terraform.workspace}-moochat-ecs-cluster"
}

resource "aws_ecs_service" "moochat_ecs_service" {
  name            = "${terraform.workspace}-moochat-ecs-service"
  cluster         = resource.aws_ecs_cluster.moochat_ecs_cluster.id
  task_definition = resource.aws_ecs_task_definition.moochat_service_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [resource.aws_security_group.sg_moochat_ecs_tasks.id,"sg-0b03f389b81b18623",
    "sg-0d3fee5cb05cef4b4"]
    subnets          = data.aws_subnet_ids.default.ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = resource.aws_lb_target_group.lb_target_group_moochat.arn
    container_name   = "moochat-socket-service"
    container_port   = 8000
  }

  depends_on = [resource.aws_lb_listener.https_forward, resource.aws_iam_role_policy_attachment.moochat_ecs_iam_policy_attachment]

  tags = {
    Environment = "${terraform.workspace}"
    Application = "moochat-socket-service"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group_moochat_socket_service" {
  name = "${terraform.workspace}-awslogs-moochat-socket-service"

  tags = {
    Environment = "${terraform.workspace}"
    Application = "moochat-socket-service"
  }
}

output "moochat_ecr_repo_arn" {
  value = resource.aws_ecr_repository.moochat_ecr_repo.arn
}

output "moochat_ecr_repo_url" {
  value = resource.aws_ecr_repository.moochat_ecr_repo.repository_url
}

output "moochat_redis_cluster_address" {
  value = resource.aws_elasticache_cluster.moochat_redis_cluster.arn
}
