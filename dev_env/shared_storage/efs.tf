resource "aws_efs_file_system" "dev_support_efs" {
   creation_token = "efs"
   performance_mode = "generalPurpose"

   tags = {
     Name = "unity-ads-${var.tenant_identifier}-efs_fs"
   }
}
