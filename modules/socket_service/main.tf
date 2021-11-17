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
  ]
  snapshot_retention_limit = 0
  snapshot_window          = "05:00-06:00"
  subnet_group_name        = "default"
  tags                     = {}
  tags_all                 = {}
}

resource "aws_ecr_repository" "moochat_ecr_repo" {
  name = "${terraform.workspace}-moochat-socket-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
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
