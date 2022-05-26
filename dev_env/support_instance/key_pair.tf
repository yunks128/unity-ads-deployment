resource "tls_private_key" "app_dev_support_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "app_dev_support_key_pair" {
  key_name   = "unity-ads-${var.tenant_identifier}-support-kp"
  public_key = tls_private_key.app_dev_support_priv_key.public_key_openssh
}


output "private_key" {
  value     = tls_private_key.app_dev_support_priv_key.private_key_pem
  sensitive = true
}
