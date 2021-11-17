resource "aws_elasticache_cluster" "moochat_redis_cluster" {
  cluster_id           = "${terraform.workspace}-moochat-redis"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
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
  value = resource.aws_elasticache_cluster.moochat_redis_cluster.cluster_address
}