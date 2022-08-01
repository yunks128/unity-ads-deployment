resource "aws_security_group" "dev_support_efs_ec2_sg" {
   name = "${var.resource_prefix}-${var.tenant_identifier}-efs-ec2-sg"
   description= "Allows inbound EFS traffic from Support EC2 Instance"
   vpc_id = data.aws_vpc.unity_vpc.id

   ingress {
     security_groups = [aws_security_group.app_dev_support_sg.id]
     from_port = 2049
     to_port = 2049
     protocol = "tcp"
   }

   egress {
     security_groups = [aws_security_group.app_dev_support_sg.id]
     from_port = 0
     to_port = 0
     protocol = "-1"
   }
}

resource "aws_efs_mount_target" "dev_support_efs_mt" {
   file_system_id  = data.aws_efs_file_system.dev_support_fs.id
   subnet_id       = data.aws_subnet.dev_support_subnet.id
   security_groups = [aws_security_group.dev_support_efs_ec2_sg.id]
}
