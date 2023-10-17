# Connect the EKS cluster OpenID connect URL as a provider
data "tls_certificate" "openid_cert" {
  url = aws_eks_cluster.jupyter_cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "eks_openid_provider" {
  url = aws_eks_cluster.jupyter_cluster.identity[0].oidc[0].issuer

  client_id_list = [ "sts.amazonaws.com" ]

  thumbprint_list = [ data.tls_certificate.openid_cert.certificates.0.sha1_fingerprint ]
}

locals {
  k8_service_account_name      = "Unity-ADS-${var.tenant_identifier}-EKSServiceAccount"
  k8_service_account_namespace = "default"

  # Get the EKS OIDC Issuer without https:// prefix
  eks_oidc_issuer = trimprefix(aws_eks_cluster.jupyter_cluster.identity[0].oidc[0].issuer, "https://")
}

#
# Create the IAM role that will be assumed by the service account
#
resource "aws_iam_role" "service_account_role" {
  name               = "${local.k8_service_account_name}"
  assume_role_policy = data.aws_iam_policy_document.service_account_policy.json
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"
}

#
# Create IAM policy allowing the k8s service account to assume the IAM role
#
data "aws_iam_policy_document" "service_account_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer}"
      ]
    }

    # Limit the scope so that only our desired service account can assume this role
    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer}:sub"
      values = [
        "system:serviceaccount:${local.k8_service_account_namespace}:${local.k8_service_account_name}"
      ]
    }
  }
}

#
# Create the Kubernetes service account which will assume the AWS IAM role
#
resource "kubernetes_service_account" "k8_service_account" {
  metadata {
    name      = local.k8_service_account_name
    namespace = local.k8_service_account_namespace
    annotations = {
      # This annotation is needed to tell the service account which IAM role it
      # should assume
      "eks.amazonaws.com/role-arn" = aws_iam_role.service_account_role.arn
    }
  }
}
