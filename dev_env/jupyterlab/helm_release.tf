provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.jupyter_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.jupyter_cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.jupyter_cluster.name]
      command     = "aws"
    }
  }
}

resource "helm_release" "jupyter_helm" {
  name       = "jupyterhub"
  repository = "https://jupyterhub.github.io/helm-chart/"
  chart      = "jupyterhub"
  namespace  = "jhub-${var.cluster_name}"
  version    = "1.2.0"

  cleanup_on_fail  = true
  create_namespace = true

  values = [
    file("${path.module}/jupyter_config.yaml")
  ]
}
