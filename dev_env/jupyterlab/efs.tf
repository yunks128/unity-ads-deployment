resource "aws_security_group" "dev_support_efs_jupyter_sg" {
   name = "unity-ads-${var.tenant_identifier}-efs-jupyter-sg"
   description= "Allows inbound EFS traffic from Jupyter cluster"
   vpc_id = data.aws_vpc.unity_vpc.id

   ingress {
     security_groups = [aws_eks_cluster.jupyter_cluster.vpc_config[0].cluster_security_group_id]
     from_port = 2049
     to_port = 2049 
     protocol = "tcp"
   }     
        
   egress {
     security_groups = [aws_eks_cluster.jupyter_cluster.vpc_config[0].cluster_security_group_id]
     from_port = 0
     to_port = 0
     protocol = "-1"
   }
}

resource "aws_efs_mount_target" "dev_support_efs_mt" {
   file_system_id  = aws_efs_file_system.dev_support_efs.id
   subnet_id       = tolist(data.aws_subnets.unity_public_subnets.ids)[0]
   security_groups = [aws_security_group.dev_support_efs_jupyter_sg.id]
}

resource "kubernetes_storage_class" "efs_storage_class" {
  metadata {
    name = "efs"
  }
  storage_provisioner = "kubernetes.io/aws-efs"
  reclaim_policy      = "Delete"
  parameters = {
  }
}

resource "kubernetes_persistent_volume" "dev_support_kube_volume" {
  metadata {
    name = "unity-ads-${var.tenant_identifier}-dev-data"
  }

  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = "efs"

    capacity = {
      storage = "100Gi"
    }

    persistent_volume_reclaim_policy = "Delete"

    persistent_volume_source {
      nfs {
	server    = aws_efs_mount_target.dev_support_efs_mt.ip_address
        path      = "/"
	read_only = false
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "dev_support_kube_volume_claim" {
  metadata {
    name = "unity-ads-${var.tenant_identifier}-dev-data"
    namespace = helm_release.jupyter_helm.namespace
  }

  spec {
    access_modes = ["ReadWriteMany"]

    # Critical that this is an empty string
    storage_class_name = "efs"

    resources {
      requests = {
        storage = "100Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.dev_support_kube_volume.metadata.0.name}"
  }
}
