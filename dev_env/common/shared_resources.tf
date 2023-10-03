data "aws_efs_file_system" "dev_support_fs" {
  tags = {
    Name = "${var.efs_identifier}"
  }
}
