resource "aws_eks_cluster" "jupyter_cluster" {
  name     = "${var.resource_prefix}-${var.tenant_identifier}-jupyter-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.24"

  vpc_config {
    subnet_ids = concat(local.az_subnet_ids[var.availability_zone_1].private,
                        local.az_subnet_ids[var.availability_zone_2].private)
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role.eks_cluster_role
  ]
}

resource "aws_eks_node_group" "jupyter_cluster_node_group" {
  cluster_name    = aws_eks_cluster.jupyter_cluster.name
  node_group_name = "${var.resource_prefix}-${var.tenant_identifier}-jupyter-nodegroup"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = concat(local.az_subnet_ids[var.availability_zone_1].private,
                           local.az_subnet_ids[var.availability_zone_2].private)

  scaling_config {
    desired_size = 4
    max_size     = 8
    min_size     = 2
  }

  disk_size = 100

  update_config {
    max_unavailable = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role.eks_node_role
  ]

  lifecycle {
    ignore_changes = [ scaling_config ]
  }
}

# Connect the EKS cluster OpenID connect URL as a provider
data "tls_certificate" "openid_cert" {
  url = aws_eks_cluster.jupyter_cluster.identity.0.oidc.0.issuer
}

# Extract the name of the EKS cluster auto scaling group for use in connecting to front end
locals {
  autoscaling_group_name = lookup(lookup(lookup(aws_eks_node_group.jupyter_cluster_node_group, "resources")[0], "autoscaling_groups")[0], "name")
}

resource "aws_iam_openid_connect_provider" "eks_openid_provider" {
  url = aws_eks_cluster.jupyter_cluster.identity[0].oidc[0].issuer

  client_id_list = [ "sts.amazonaws.com" ]

  thumbprint_list = [ data.tls_certificate.openid_cert.certificates.0.sha1_fingerprint ]
}

output "eks_cluster_name" {
  value = aws_eks_cluster.jupyter_cluster.name
}
