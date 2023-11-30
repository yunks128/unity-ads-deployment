output "jupyter_base_path" {
  value = ""
}

output "jupyter_base_url" {
  value = "https://${aws_lb.jupyter_alb.dns_name}:${var.load_balancer_port}"
}
