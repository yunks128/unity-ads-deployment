# Application Load Balancer connecting to EKS cluster
resource "aws_lb" "jupyter_alb" {
  name               = "jupyter-${var.tenant_identifier}-alb"
  load_balancer_type = "application"
  security_groups    = [ "${aws_security_group.jupyter_alb_sg.id}" ]
  subnets            = data.aws_subnets.unity_public_subnets.ids

  tags = {
    Name = "${var.resource_prefix}-${var.tenant_identifier}-jupyter-alb"
  }
}

resource "aws_lb_target_group" "jupyter_alb_target_group" {
  name        = "jupyter-${var.tenant_identifier}-alb-tg"
  target_type = "instance"
  port        = var.jupyter_proxy_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.unity_vpc.id

  tags = {
    name = "${var.resource_prefix}-${var.tenant_identifier}-alb-target-group"
  }

  # alter the destination of the health check
  health_check {
    path = "${local.jupyter_api_path}/hub/health"
    port = var.jupyter_proxy_port
  }
}

resource "aws_lb_listener" "jupyter_alb_listener" {
  load_balancer_arn = aws_lb.jupyter_alb.arn
  port              = var.load_balancer_port
  protocol          = "HTTP"

  tags = {
    Name = "${var.resource_prefix}-${var.tenant_identifier}-alb-listener"
  }

  default_action {
    target_group_arn = aws_lb_target_group.jupyter_alb_target_group.arn
    type             = "forward"
  }
}

# Network Load Balancer connecting to ALB for use by API
resource "aws_lb" "jupyter_nlb" {
  name               = "jupyter-${var.tenant_identifier}-nlb"
  load_balancer_type = "network"
  subnets            = data.aws_subnets.unity_public_subnets.ids

  tags = {
    Name = "${var.resource_prefix}-${var.tenant_identifier}-jupyter-nlb"
  }
}

resource "aws_lb_target_group" "jupyter_nlb_target_group" {
  name        = "jupyter-${var.tenant_identifier}-nlb-tg"
  port        = aws_lb_listener.jupyter_alb_listener.port
  target_type = "alb"
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.unity_vpc.id

  tags = {
    name = "${var.resource_prefix}-${var.tenant_identifier}-nlb-target-group"
  }

  # alter the destination of the health check
  health_check {
    path = "${local.jupyter_api_path}/hub/health"
    port = aws_lb_listener.jupyter_alb_listener.port
  }
}

resource "aws_lb_target_group_attachment" "jupyter_nlb_tg_attachment" {
  target_group_arn = aws_lb_target_group.jupyter_nlb_target_group.arn
  target_id        = aws_lb.jupyter_alb.arn
  port             = aws_lb_listener.jupyter_alb_listener.port
  depends_on       = [ aws_lb.jupyter_alb ]
}

resource "aws_lb_listener" "jupyter_nlb_listener" {
  load_balancer_arn = aws_lb.jupyter_nlb.arn
  port              = aws_lb_listener.jupyter_alb_listener.port
  protocol          = "TCP"

  tags = {
    Name = "${var.resource_prefix}-${var.tenant_identifier}-nlb-listener"
  }

  default_action {
    target_group_arn = aws_lb_target_group.jupyter_nlb_target_group.arn
    type             = "forward"
  }
}
