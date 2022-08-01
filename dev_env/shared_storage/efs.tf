resource "aws_efs_file_system" "dev_support_efs" {
   creation_token = "efs"
   performance_mode = "generalPurpose"

   tags = {
     Name = "${var.resource_prefix}-${var.tenant_identifier}-efs-fs"
   }
}
