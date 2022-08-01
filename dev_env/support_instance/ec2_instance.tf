data "aws_subnet" "dev_support_subnet" {
  id = data.aws_subnets.unity_private_subnets.ids[1]
}

resource "aws_instance" "dev_support_ec2" {
  ami            = "ami-043738bfa891187cc"
  instance_type  = "t2.micro"

  key_name      = aws_key_pair.dev_support_key_pair.key_name

  availability_zone = data.aws_subnet.dev_support_subnet.availability_zone
  subnet_id         = data.aws_subnet.dev_support_subnet.id

  vpc_security_group_ids = [ aws_security_group.app_dev_support_sg.id ]

  iam_instance_profile = "MCP-SSM-CloudWatch"

  tags = {
    Name = "${var.resource_prefix}-${var.tenant_identifier}-support-instance"
  }

  root_block_device {
    delete_on_termination = "true"

    volume_size = "16"
    volume_type = "gp2"
  }

  user_data = templatefile("init.sh", {
    efs_ip_address = aws_efs_mount_target.dev_support_efs_mt.ip_address
  })

}
