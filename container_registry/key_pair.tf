resource "tls_private_key" "quay_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "quay_key_pair" {
  key_name   = "${var.resource_prefix}-${var.tenant_identifier}-quay-kp"
  public_key = tls_private_key.quay_priv_key.public_key_openssh
}

output "private_key_pem" {
  value = tls_private_key.quay_priv_key.private_key_pem
  sensitive = true
}
