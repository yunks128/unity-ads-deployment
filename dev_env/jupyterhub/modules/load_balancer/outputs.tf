output "jupyter_base_path" {
  value = var.jupyter_base_path
}

output "jupyter_base_url" {
  value = var.jupyter_base_url != null ? var.jupyter_base_url : "https://${aws_lb.jupyter_alb.dns_name}:${var.load_balancer_port}"
}

output "internal_base_url" {
  value = "https://${aws_lb.jupyter_alb.dns_name}:${var.load_balancer_port}"
}
