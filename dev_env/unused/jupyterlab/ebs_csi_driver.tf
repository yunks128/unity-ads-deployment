# The following is necessary for EKS version 1.23 or greater to allow for persistent storage
# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${aws_eks_cluster.jupyter_cluster.name}"
  provider_url                  = replace(aws_eks_cluster.jupyter_cluster.identity.0.oidc.0.issuer, "https://", "")
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]

  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
  role_permissions_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = aws_eks_cluster.jupyter_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  #addon_version            = "v1.5.2-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}
