data "aws_subnet" "quay_subnet" {
  id = data.aws_subnets.unity_private_subnets.ids[1]
}

data "aws_ssm_parameter" "ami" {
  name = "/mcp/amis/rhel8"
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
  })

}

output "instance_id" {
  value = aws_instance.quay_ec2.id
}
