resource "aws_ebs_volume" "app_dev_support_volume" {
  size = "50"
  type = "gp3"

  availability_zone = var.app_dev_support_zone

  tags = {
    Name = "unity-ads-${var.tenant_identifier}-app-dev-data"
  }

}

resource "aws_volume_attachment" "support_ebs_att" {
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.app_dev_support_volume.id
  instance_id = aws_instance.app_dev_support_ec2.id
}
