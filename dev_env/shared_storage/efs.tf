resource "aws_efs_file_system" "dev_support_efs" {
   creation_token = "efs"
   performance_mode = "generalPurpose"

   tags = {
     Name = "${var.efs_identifier}"
   }
}

resource "aws_efs_access_point" "jupyter_shared" {
  file_system_id = aws_efs_file_system.dev_support_efs.id
  root_directory {
    path = "/shared"
    creation_info {
       owner_uid = 0
       owner_gid = 0
       permissions = 755
    }
  }
}
