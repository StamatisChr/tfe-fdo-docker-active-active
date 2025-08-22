data "cloudinit_config" "tfe_user_data" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("tfe-cloud-config.yaml", {
      aws_region                     = var.aws_region
      tfe_license                    = var.tfe_license
      tfe_version_image              = var.tfe_version_image
      tfe_hostname                   = "${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}"
      tfe_http_port                  = var.tfe_http_port
      tfe_https_port                 = var.tfe_https_port
      tfe_encryption_password        = var.tfe_encryption_password
      tfe_host_path_to_certificates  = var.tfe_host_path_to_certificates
      cert                           = var.lets_encrypt_cert
      bundle                         = var.lets_encrypt_cert
      key                            = var.lets_encrypt_key
      tfe_database_user              = var.tfe_database_user
      tfe_database_name              = var.tfe_database_name
      tfe_database_password          = var.tfe_database_password
      tfe_database_host              = aws_db_instance.tfe_postgres.endpoint
      tfe_object_storage_bucket_name = "${tolist(local.bucket_names)[0]}-${random_pet.hostname_suffix.id}"
      tfe_shared_bucket_name         = "${tolist(local.bucket_names)[1]}-${random_pet.hostname_suffix.id}"
      tfe_redis_host                 = aws_elasticache_cluster.tfe_redis.cache_nodes[0].address
      tfe_iact_token                 = random_string.iact_token.result
    })
  }
}

resource "aws_launch_template" "tfe_launch_template" {
  name_prefix   = "tfe-${random_pet.hostname_suffix.id}"
  image_id      = data.aws_ami.ubuntu_2404.id
  instance_type = var.tfe_instance_class
  ebs_optimized = true

  user_data = data.cloudinit_config.tfe_user_data.rendered

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 120
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_s3_access.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.tfe_sg.id]
  }

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "optional"
    instance_metadata_tags = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "tfe-${random_pet.hostname_suffix.id}"
    }
  }
}
