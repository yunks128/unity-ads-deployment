resource "aws_ebs_volume" "app_dev_support_volume" {
  size = "50"
  type = "gp3"

  availability_zone = "us-west-2b"

  tags = {
    Name = "unity-ads-${var.tenant_identifier}-app-dev-data"
  }

}

resource "aws_volume_attachment" "support_ebs_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.app_dev_support_volume.id
  instance_id = aws_instance.app_dev_support_ec2.id
}
