## random pet name to make the TFE fqdn change in every deployment 
resource "random_pet" "hostname_suffix" {
  length = 2
}

resource "random_string" "iact_token" {
  length  = 16
  special = false
}

#### EC2 security group ######
resource "aws_security_group" "tfe_sg" {
  name        = "tfe_sg-${random_pet.hostname_suffix.id}"
  description = "Allow inbound traffic and outbound traffic for TFE"

  tags = {
    Name = "tfe-${random_pet.hostname_suffix.id}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "port_443_https" {
  security_group_id = aws_security_group.tfe_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "port_80_http" {
  security_group_id = aws_security_group.tfe_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "port_6379_redis" {
  security_group_id = aws_security_group.tfe_sg.id
  cidr_ipv4         = data.aws_vpc.default.cidr_block
  from_port         = 6379
  ip_protocol       = "tcp"
  to_port           = 6379
}

resource "aws_vpc_security_group_ingress_rule" "port_8201_vault" {
  security_group_id = aws_security_group.tfe_sg.id
  cidr_ipv4         = data.aws_vpc.default.cidr_block
  from_port         = 8201
  ip_protocol       = "tcp"
  to_port           = 8201
}


resource "aws_vpc_security_group_ingress_rule" "port_5432_postgres" {
  security_group_id = aws_security_group.tfe_sg.id
  cidr_ipv4         = data.aws_vpc.default.cidr_block
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_traffic_ipv4" {
  security_group_id = aws_security_group.tfe_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# IAM Role for EC2 to access S3 
resource "aws_iam_role" "ec2_s3_access" {
  name = "ec2_s3_access_role-${random_pet.hostname_suffix.id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Name = "stam-${random_pet.hostname_suffix.id}"
  }
}

# policy to allow ec2 to access only the tfe s3 bucket 
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3_access_policy-${random_pet.hostname_suffix.id}"
  description = "Policy to allow EC2 access to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = ["s3:*"]
      Effect = "Allow",
      Resource = concat(
        [for bucket in aws_s3_bucket.tfe_bucket : bucket.arn],
        [for bucket in aws_s3_bucket.tfe_bucket : "${bucket.arn}/*"]
      )
    }]
  })

  tags = {
    Name = "stam-${random_pet.hostname_suffix.id}"
  }
}

resource "aws_iam_role_policy_attachment" "s3_attach" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.ec2_s3_access.name

}

resource "aws_iam_instance_profile" "ec2_s3_access" {
  name = "ec2_s3_access_profile-${random_pet.hostname_suffix.id}"
  role = aws_iam_role.ec2_s3_access.name

  tags = {
    Name = "tfe-${random_pet.hostname_suffix.id}"
  }
}

resource "aws_iam_role_policy_attachment" "SSM" {
  role       = aws_iam_role.ec2_s3_access.name
  policy_arn = data.aws_iam_policy.SecurityComputeAccess.arn
}


# DNS 
resource "aws_route53_record" "tfe" {
  zone_id = data.aws_route53_zone.my_aws_dns_zone.id
  name    = "${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}"
  type    = "CNAME"
  ttl     = 60
  records = [aws_lb.tfe_load_balancer.dns_name]

}

resource "aws_db_instance" "tfe_postgres" {
  identifier             = "tfe-p-${random_pet.hostname_suffix.id}"
  engine                 = "postgres"
  engine_version         = "14.17"
  instance_class         = var.db_instance_class
  allocated_storage      = 50
  storage_type           = "gp3"
  username               = var.tfe_database_user
  db_name                = var.tfe_database_name
  password               = var.tfe_database_password
  vpc_security_group_ids = [aws_security_group.tfe_sg.id]
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = {
    Name = "stam-${random_pet.hostname_suffix.id}"
  }
}


resource "aws_elasticache_cluster" "tfe_redis" {
  cluster_id           = "tfe-redis-${random_pet.hostname_suffix.id}"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.1"
  port                 = 6379
  security_group_ids   = [aws_security_group.tfe_sg.id]

  tags = {
    Name = "tfe-${random_pet.hostname_suffix.id}"
  }
}
