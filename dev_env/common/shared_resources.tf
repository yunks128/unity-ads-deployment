data "aws_efs_file_system" "dev_support_fs" {
  tags = {
    Name = "${var.resource_prefix}-${var.tenant_identifier}-efs-fs"
  }
}
