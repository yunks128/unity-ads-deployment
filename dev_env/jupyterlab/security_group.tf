resource "aws_security_group" "jupyter_alb_sg" {
  name        = "${var.resource_prefix}-${var.tenant_identifier}-lb-sg"
  description = "U-ADS ${var.tenant_identifier} JupyterHub application load balancer security group"

  vpc_id = data.aws_vpc.unity_vpc.id

  tags = {
    Name = "${var.resource_prefix}-${var.tenant_identifier}-lb-sg"
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow from variable defined input port
  ingress {
    from_port   = "${var.load_balancer_port}"
    to_port     = "${var.load_balancer_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "jupyter_cluster_allow_lb" {
  type                     = "ingress"
  from_port                = "30000"
  to_port                  = "32767"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jupyter_alb_sg.id
  security_group_id        = aws_eks_cluster.jupyter_cluster.vpc_config[0].cluster_security_group_id
}
