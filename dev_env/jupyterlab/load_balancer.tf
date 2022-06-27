resource "aws_alb" "jupyter_alb" {
  name            = "jupyter-${var.tenant_identifier}-alb"
  security_groups = [ "${aws_security_group.jupyter_alb_sg.id}" ]
  subnets         = data.aws_subnets.unity_public_subnets.ids
  tags = {
    Name = "unity-ads-${var.tenant_identifier}-jupyter-alb"
  }
}

resource "aws_alb_target_group" "jupyter_alb_target_group" {
  name     = "jupyter-${var.tenant_identifier}-tg"
  port     = var.jupyter_proxy_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.unity_vpc.id

  tags = {
    Name = "unity-ads-${var.tenant_identifier}-alb-target-group"
  }

  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/hub/login"
    port = var.jupyter_proxy_port
  }
}

resource "aws_alb_target_group_attachment" "jupyter_alb_tg_attachment" {
  target_group_arn = aws_alb_target_group.jupyter_alb_target_group.arn

  for_each  = toset(data.aws_instances.jupyter_cluster_instances.ids)
  target_id = each.key

  #count       = length( aws_instance.xxx-IIS-004 )
  #instance    = split("_", local.att_004)[count.index]

  depends_on  = [ aws_eks_node_group.jupyter_cluster_node_group ]
}

resource "aws_alb_listener" "jupyter_alb_listener" {
  load_balancer_arn = "${aws_alb.jupyter_alb.arn}"
  port              = var.load_balancer_port
  protocol          = "HTTP"

  tags = {
    Name = "unity-ads-${var.tenant_identifier}-alb-listener"
  }

  default_action {
    target_group_arn = "${aws_alb_target_group.jupyter_alb_target_group.arn}"
    type             = "forward"
  }
}
