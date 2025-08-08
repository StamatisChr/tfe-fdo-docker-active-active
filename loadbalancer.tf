resource "aws_lb_target_group" "tfe_http_tg" {
  name     = "TFE-HTTP"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-031fcae7f0e8d20b4"

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
    protocol            = "HTTP"
  }

  protocol_version = "HTTP1"
  ip_address_type  = "ipv4"
}


resource "aws_lb" "tfe_load_balancer" {
  name               = "tfe-aa-lb"
  internal           = false # 'internet-facing' equates to internal = false
  load_balancer_type = "application"
  security_groups    = ["sg-06240eee418567a2a"]
  subnets = [
    "subnet-08bdbca69cccf622f",
    "subnet-0e9702922ae2b5368",
    "subnet-0bba38a13b4feb7b7",
  ]
  ip_address_type = "ipv4"

  tags = {
    Name        = "stam-test-lb"
    Environment = "dev" # Example tag
  }
}

# Define the Listener for the Application Load Balancer
resource "aws_lb_listener" "tfe_http" {
  load_balancer_arn = aws_lb.tfe_load_balancer.arn # Reference to the ALB created above
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfe_http_tg.arn
  }

  tags = {
    Name        = "tfe-aa-listener"
    Environment = "dev"
  }
}
