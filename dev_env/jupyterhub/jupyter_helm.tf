resource "helm_release" "jupyter_helm" {
  name       = "jupyterhub"
  repository = "https://jupyterhub.github.io/helm-chart"
  chart      = "jupyterhub"
  namespace  = "jhub-${var.tenant_identifier}"
  version    = "3.1.0"

  cleanup_on_fail  = true
  create_namespace = true

  values = [
    templatefile("${path.module}/jupyter_config.yaml", {
      cognito_oauth_base_url = var.cognito_oauth_base_url
      oauth_client_id        = var.cognito_oauth_client_id
      oauth_client_secret    = var.cognito_oauth_client_secret
      jupyter_base_path      = module.frontend.jupyter_base_path != "" ? "/${module.frontend.jupyter_base_path}/" : "/"
      jupyter_base_url       = module.frontend.jupyter_base_url
      jupyter_proxy_port     = var.jupyter_proxy_port
      shared_volume_name     = "${kubernetes_persistent_volume.dev_support_shared_volume.metadata.0.name}"
      unity_auth_py          = base64encode(file("${path.module}/unity_auth.py"))
    })
  ]

  # Need to wait for ALB to get created
  depends_on = [
    module.frontend,
    module.eks,
  ]
}

output "kube_namespace" {
  value = helm_release.jupyter_helm.namespace
}
