data "aws_efs_file_system" "dev_support_fs" {
  tags = {
    Name = "unity-ads-${var.tenant_identifier}-efs_fs"
  }
}
