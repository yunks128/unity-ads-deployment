output "proxy_proto" {
  value = nonsensitive(local.proxy_proto)
}

output "proxy_address" {
  value = nonsensitive(local.proxy_address)
}

output "proxy_port" {
  value = nonsensitive(local.proxy_port)
}

output "jupyter_base_path" {
  value = nonsensitive(module.frontend.jupyter_base_path)
}

output "jupyter_base_url" {
  value = nonsensitive(module.frontend.jupyter_base_url)
}

output "internal_base_url" {
  value = nonsensitive(module.frontend.internal_base_url)
}
