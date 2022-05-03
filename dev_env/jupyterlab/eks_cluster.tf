resource "aws_eks_cluster" "jupyter_cluster" {
  name     = "unity-ads-${var.cluster_name}-jupyter-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.22"

  vpc_config {
    subnet_ids = data.aws_subnets.unity_vpc_subnets.ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role.eks_cluster_role
  ]
}

output "endpoint" {
  value = aws_eks_cluster.jupyter_cluster.endpoint
}

resource "aws_eks_node_group" "jupyter_cluster_node_group" {
  cluster_name    = aws_eks_cluster.jupyter_cluster.name
  node_group_name = "unity-ads-${var.cluster_name}-jupyter-nodegroup"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = data.aws_subnets.unity_vpc_subnets.ids

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  update_config {
    max_unavailable = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role.eks_node_role
  ]
}
