resource "tls_private_key" "dev_support_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "dev_support_key_pair" {
  key_name   = "${var.resource_prefix}-${var.tenant_identifier}-support-kp"
  public_key = tls_private_key.dev_support_priv_key.public_key_openssh
}
