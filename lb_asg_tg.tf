locals {
  target_group_ports = {
    http = {
      port     = 80,
      protocol = "HTTP"
    }
    https = {
      port = 443,
    protocol = "HTTPS" }
  }
}

resource "aws_lb_target_group" "tfe_tg" {
  for_each = local.target_group_ports

  name        = "tfe-${upper(each.key)}-${random_pet.hostname_suffix.id}"
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/_health_check"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
    port                = "traffic-port"
    protocol            = each.value.protocol
  }

  ip_address_type = "ipv4"
}

resource "aws_lb_listener" "tfe_listener" {
  for_each          = local.target_group_ports
  load_balancer_arn = aws_lb.tfe_load_balancer.arn
  port              = each.value.port
  protocol          = each.value.protocol

  certificate_arn = each.key == "https" ? aws_acm_certificate.acm_cert.arn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfe_tg[each.key].arn
  }

  tags = {
    Name = "tfe-${random_pet.hostname_suffix.id}-${each.key}"
  }
}

resource "aws_lb" "tfe_load_balancer" {
  name               = "tfe-${random_pet.hostname_suffix.id}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tfe_sg.id]
  subnets            = data.aws_subnets.default-vpc-subnets.ids
  ip_address_type    = "ipv4"

  tags = {
    Name = "tfe-${random_pet.hostname_suffix.id}"
  }
}

resource "aws_autoscaling_group" "tfe_aa" {
  vpc_zone_identifier = data.aws_subnets.default-vpc-subnets.ids

  desired_capacity = 1
  max_size         = 3
  min_size         = 1

  target_group_arns = [
    for target_group in aws_lb_target_group.tfe_tg : target_group.arn
  ]

  launch_template {
    id      = aws_launch_template.tfe_launch_template.id
    version = "$Latest"
  }
}
