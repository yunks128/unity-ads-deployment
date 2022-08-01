resource "aws_security_group" "app_dev_support_sg" {
  name        = "${var.resource_prefix}-${var.tenant_identifier}-support-sg"
  description = "U-ADS development environment support security group"

  vpc_id = data.aws_vpc.unity_vpc.id

  tags = {
    Name = "${var.resource_prefix}-${var.tenant_identifier}-support-sg"
  }

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
