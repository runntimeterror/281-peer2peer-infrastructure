resource "aws_elasticache_cluster" "moochat_redis_cluster" {
  cluster_id           = "${terraform.workspace}-moochat-redis"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
}

output "moochat_redis_cluster_address" {
  value = resource.aws_elasticache_cluster.moochat_redis_cluster.cluster_address
}