resource "aws_ebs_volume" "dev_support_ebs_volume" {
  size = "100"
  type = "io1"
  iops = 3000

  multi_attach_enabled = true

  availability_zone = var.ebs_availability_zone

  tags = {
    Name = "unity-ads-${var.tenant_identifier}-dev-data"
  }

}

resource "kubernetes_storage_class" "io1_storage_class" {
  metadata {
    name = "io1"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Delete"
  parameters = {
    type = "io1"
    fsType = "ext4"
  }
}

resource "kubernetes_persistent_volume" "dev_support_kube_volume" {
  metadata {
    name = "unity-ads-${var.tenant_identifier}-dev-data"
  }

  spec {
    access_modes = ["ReadOnlyMany"]

    capacity = {
      storage = "100Gi"
    }

    storage_class_name = "io1"
    persistent_volume_reclaim_policy = "Delete"

    persistent_volume_source {
      aws_elastic_block_store {
        fs_type = "ext4"
        volume_id = aws_ebs_volume.dev_support_ebs_volume.id
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
    access_modes = ["ReadOnlyMany"]
    resources {
      requests = {
        storage = "100Gi"
      }
    }
    storage_class_name = "io1"
    volume_name = "${kubernetes_persistent_volume.dev_support_kube_volume.metadata.0.name}"
  }
}
