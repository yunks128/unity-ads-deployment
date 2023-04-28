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

  vpc_security_group_ids = [ aws_security_group.quay_sg.id ]

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
    cognito_oidc_base_url = var.cognito_oidc_base_url
    cognito_user_pool_id = tolist(data.aws_cognito_user_pools.unity_user_pool.ids)[0]
    cognito_quay_client_id = var.cognito_quay_client_id
    cognito_quay_client_secret = var.cognito_quay_client_secret
    postgresql_user_password = random_password.postgresql_user_password.result
    postgresql_admin_password = random_password.postgresql_admin_password.result
    redis_password = random_password.redis_password.result
  })

}

output "instance_id" {
  value = aws_instance.quay_ec2.id
}
