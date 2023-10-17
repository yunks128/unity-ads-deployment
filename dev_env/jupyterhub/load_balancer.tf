# Application Load Balancer connecting to EKS cluster
resource "aws_lb" "jupyter_alb" {
  name               = "jupyter-${var.tenant_identifier}-alb"
  load_balancer_type = "application"
  security_groups    = [ "${aws_security_group.jupyter_alb_sg.id}" ]
  subnets            = concat(local.az_subnet_ids[var.availability_zone_1].public,
                              local.az_subnet_ids[var.availability_zone_2].public)

  tags = {
    Name = "${var.resource_prefix}-${var.tenant_identifier}-jupyter-alb"
  }
}

resource "aws_lb_target_group" "jupyter_alb_target_group" {
  name        = "jupyter-${var.tenant_identifier}-alb-tg"
  target_type = "instance"
  vpc_id      = data.aws_vpc.unity_vpc.id

  protocol         = "HTTP"
  port             = var.jupyter_proxy_port

  tags = {
    name = "${var.resource_prefix}-${var.tenant_identifier}-alb-target-group"
  }

  # alter the destination of the health check
  health_check {
    path = "${local.jupyter_base_path}/hub/health"
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
    common_name  = "Unity ${var.tenant_identifier} JupyterHub"
    organization = "${var.unity_instance}"
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
  name             = "Unity-${var.tenant_identifier}-JupyterHub-Certificate-${random_id.cert.hex}"
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
    Name = "${var.resource_prefix}-${var.tenant_identifier}-alb-listener"
  }

  default_action {
    target_group_arn = aws_lb_target_group.jupyter_alb_target_group.arn
    type             = "forward"
  }
}

locals {
  jupyter_base_url = "https://${aws_lb.jupyter_alb.dns_name}:${var.load_balancer_port}"
}

locals {
  jupyter_base_path = "/"
}

output "jupyter_base_uri" {
  value = local.jupyter_base_url
}
