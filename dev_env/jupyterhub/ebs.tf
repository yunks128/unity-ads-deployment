resource "kubernetes_storage_class" "ebs_storage_class" {

  metadata {
    name = "ebs"
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Retain"

  parameters = {
    fsType = "ext4"
    type = "gp2"

    tagSpecification_1 = "ServiceArea=аds"
    tagSpecification_2 = "Proj=unity"
    tagSpecification_3 = "Venue=${var.tenant_identifier}"
    tagSpecification_4 = "Component=${var.component_cost_name}"
    tagSpecification_5 = "CreatedBy=ads"
    tagSpecification_6 = "Env=${var.resource_prefix}"
    tagSpecification_7 = "Stack=${var.component_cost_name}"
  }

}
