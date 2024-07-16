##########################################################
# Application Load Balancer connecting to the EKS cluster

resource "aws_lb" "jupyter_alb" {
  name               = "jupyter-${var.venue_prefix}${var.venue}-alb"
  load_balancer_type = "application"
  security_groups    = [ var.security_group_id ]
  subnets            = var.lb_subnet_ids

  tags = {
    Name = "${var.resource_prefix}-${var.venue_prefix}${var.venue}-jupyter-alb"
  }
}

resource "aws_lb_target_group" "jupyter_alb_target_group" {
  name        = "jupyter-${var.venue_prefix}${var.venue}-alb-tg"
  target_type = "instance"
  vpc_id      = var.vpc_id

  protocol         = "HTTP"
  port             = var.jupyter_proxy_port

  tags = {
    name = "${var.resource_prefix}-${var.venue_prefix}${var.venue}-alb-target-group"
  }

  # alter the destination of the health check
  health_check {
    path = var.jupyter_base_path != "" ? "/${var.jupyter_base_path}/hub/health" : "/hub/health"
    port = var.jupyter_proxy_port
  }
}

resource "tls_private_key" "jupyter_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "jupyter_alb_certificate_data" {
  private_key_pem = tls_private_key.jupyter_priv_key.private_key_pem

  dns_names = [ aws_lb.jupyter_alb.dns_name ]

  subject {
    common_name  = "Unity ${var.venue_prefix}${var.venue} JupyterHub"
    organization = "${var.resource_prefix}-${var.venue_prefix}${var.venue}"
  }

  # About half a year
  validity_period_hours = 4320

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
      
  depends_on = [ aws_lb.jupyter_alb ]
}

resource "random_id" "cert" {
  keepers = {
    cert_expiration = tls_self_signed_cert.jupyter_alb_certificate_data.validity_end_time
  }

  byte_length = 8
}

# For example, this can be used to populate an AWS IAM server certificate.
resource "aws_iam_server_certificate" "jupyter_alb_server_certificate" {
  name             = "Unity-${var.venue_prefix}${var.venue}-JupyterHub-Certificate-${random_id.cert.hex}"
  certificate_body = tls_self_signed_cert.jupyter_alb_certificate_data.cert_pem
  private_key      = tls_private_key.jupyter_priv_key.private_key_pem

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "jupyter_alb_listener" {
  load_balancer_arn = aws_lb.jupyter_alb.arn
  port              = var.load_balancer_port
  protocol          = "HTTPS"
  certificate_arn  = aws_iam_server_certificate.jupyter_alb_server_certificate.arn

  tags = {
    Name = "${var.resource_prefix}-${var.venue_prefix}${var.venue}-alb-listener"
  }

  default_action {
    target_group_arn = aws_lb_target_group.jupyter_alb_target_group.arn
    type             = "forward"
  }
}

# Attach eks node_group to load balancer through the autoscaling group
# Solution from here: https://github.com/aws/containers-roadmap/issues/709
resource "aws_autoscaling_attachment" "autoscaling_attachment" {
  autoscaling_group_name = var.autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.jupyter_alb_target_group.arn
}
