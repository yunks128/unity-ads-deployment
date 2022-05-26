resource "aws_instance" "app_dev_support_ec2" {
  ami            = "ami-043738bfa891187cc"
  instance_type  = "t2.micro"
  #instance_state = "stopped"

  key_name      = aws_key_pair.app_dev_support_key_pair.key_name

  availability_zone = var.app_dev_support_zone
  subnet_id = data.aws_subnet.app_dev_support_zone_subnet.id
  vpc_security_group_ids = [ aws_security_group.app_dev_support_sg.id ]

  iam_instance_profile = "MCP-SSM-CloudWatch"

  tags = {
    Name = "unity-ads-${var.tenant_identifier}-support-instance"
  }

  root_block_device {
    delete_on_termination = "true"

    volume_size = "16"
    volume_type = "gp2"
  }

  user_data = "${file("init_data_volume.sh")}"

}
