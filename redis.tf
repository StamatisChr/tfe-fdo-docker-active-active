resource "aws_elasticache_cluster" "tfe_redis" {
  cluster_id           = "tfe-redis-${random_pet.hostname_suffix.id}"
  engine               = "redis"
  node_type            = "cache.t3.medium"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.1"
  port                 = 6379
}