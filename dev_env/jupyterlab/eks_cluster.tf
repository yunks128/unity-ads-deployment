resource "aws_eks_cluster" "jupyter_cluster" {
  name     = "${var.resource_prefix}-${var.tenant_identifier}-jupyter-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.22"

  vpc_config {
    subnet_ids = data.aws_subnets.unity_public_subnets.ids
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
  subnet_ids      = data.aws_subnets.unity_public_subnets.ids

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

# Attach eks node_group to load balancer through the autoscaling group
# Solution from here: https://github.com/aws/containers-roadmap/issues/709
resource "aws_autoscaling_attachment" "autoscaling_attachment" {
  autoscaling_group_name = lookup(lookup(lookup(aws_eks_node_group.jupyter_cluster_node_group, "resources")[0], "autoscaling_groups")[0], "name")
  lb_target_group_arn   = aws_lb_target_group.jupyter_alb_target_group.arn
}
