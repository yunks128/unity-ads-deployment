# Application Load Balancer connecting to EKS cluster
resource "aws_lb" "quay_alb" {
  name               = "quay-${var.tenant_identifier}-alb"
  load_balancer_type = "application"
  security_groups    = [ "${aws_security_group.quay_alb_sg.id}" ]
  subnets            = data.aws_subnets.unity_public_subnets.ids

  tags = {
    Name = "${var.resource_prefix}-${var.tenant_identifier}-quay-alb"
  }
}

resource "aws_lb_target_group" "quay_alb_target_group" {
  name        = "quay-${var.tenant_identifier}-alb-tg"
  target_type = "instance"
  vpc_id      = data.aws_vpc.unity_vpc.id

  protocol         = "HTTP"
  port             = var.quay_server_port

  tags = {
    name = "${var.resource_prefix}-${var.tenant_identifier}-alb-target-group"
  }
}

resource "tls_self_signed_cert" "quay_alb_certificate_data" {
  private_key_pem = file("private_key.pem")

  dns_names = [ aws_lb.quay_alb.dns_name ]

  subject {
    common_name  = "Unity ${var.tenant_identifier} Quay Docker Server"
    organization = "${var.unity_instance}"
  }

  # About half a year
  validity_period_hours = 4320

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
      
  depends_on = [ aws_lb.quay_alb ]
}

resource "random_id" "cert" {
  keepers = {
    cert_expiration = tls_self_signed_cert.quay_alb_certificate_data.validity_end_time
  }

  byte_length = 8
}

# For example, this can be used to populate an AWS IAM server certificate.
resource "aws_iam_server_certificate" "quay_alb_server_certificate" {
  name             = "Unity-${var.tenant_identifier}-Quay-Certificate-${random_id.cert.hex}"
  certificate_body = tls_self_signed_cert.quay_alb_certificate_data.cert_pem
  private_key      = file("private_key.pem")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "quay_alb_listener" {
  load_balancer_arn = aws_lb.quay_alb.arn
  port              = var.load_balancer_port
  protocol          = "HTTPS"
  certificate_arn  = aws_iam_server_certificate.quay_alb_server_certificate.arn

  tags = {
    Name = "${var.resource_prefix}-${var.tenant_identifier}-alb-listener"
  }

  default_action {
    target_group_arn = aws_lb_target_group.quay_alb_target_group.arn
    type             = "forward"
  }
}

locals {
  quay_base_url = "https://${aws_lb.quay_alb.dns_name}:${var.load_balancer_port}"
}

output "quay_base_uri" {
  value = local.quay_base_url
}
