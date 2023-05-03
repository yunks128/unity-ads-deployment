data "aws_subnet" "quay_subnet" {
  id = data.aws_subnets.unity_private_subnets.ids[1]
}

data "aws_ssm_parameter" "ami" {
  name = "/mcp/amis/rhel8"
}

data "aws_cognito_user_pools" "unity_user_pool" {
  name = var.cognito_user_pool_name
}

resource "random_password" "postgresql_user_password" {
  length           = 25
  special          = false
}

resource "random_password" "postgresql_admin_password" {
  length           = 25
  special          = false
}

resource "random_password" "redis_password" {
  length           = 25
  special          = false
}

resource "aws_instance" "quay_ec2" {
  ami            = data.aws_ssm_parameter.ami.value
  instance_type  = "t2.medium"

  key_name      = aws_key_pair.quay_key_pair.key_name

  availability_zone = data.aws_subnet.quay_subnet.availability_zone
  subnet_id         = data.aws_subnet.quay_subnet.id

  vpc_security_group_ids = [ aws_security_group.quay_ec2_sg.id ]

  iam_instance_profile = "MCP-SSM-CloudWatch"

  tags = {
    Name = "${var.resource_prefix}-${var.tenant_identifier}-quay-instance"
  }

  root_block_device {
    delete_on_termination = "true"

    volume_size = "64"
    volume_type = "gp2"
  }

  user_data = templatefile("init.sh", {
    quay_server_hostname = aws_lb.quay_alb.dns_name
    quay_server_external_port = var.load_balancer_port
    quay_server_internal_port = var.quay_server_port
    cognito_oidc_base_url = var.cognito_oidc_base_url
    cognito_user_pool_id = tolist(data.aws_cognito_user_pools.unity_user_pool.ids)[0]
    cognito_quay_client_id = var.cognito_quay_client_id
    cognito_quay_client_secret = var.cognito_quay_client_secret
    postgresql_user_password = random_password.postgresql_user_password.result
    postgresql_admin_password = random_password.postgresql_admin_password.result
    redis_password = random_password.redis_password.result
  })

  # Need to wait for ALB to get created
  depends_on = [ aws_lb.quay_alb ]
}

resource "aws_lb_target_group_attachment" "quay_target_attachment" {
  target_group_arn = aws_lb_target_group.quay_alb_target_group.arn
  target_id        = aws_instance.quay_ec2.id
  port             = var.quay_server_port
}

output "instance_id" {
  value = aws_instance.quay_ec2.id
}
