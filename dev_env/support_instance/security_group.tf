resource "aws_security_group" "app_dev_support_sg" {
  name        = "unity-ads-${var.tenant_identifier}-dev-env-support-sg"
  description = "U-ADS development environment support security group"

  vpc_id = data.aws_vpc.unity_vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "22"
    protocol    = "tcp"
    self        = "false"
    to_port     = "22"
  }

}
