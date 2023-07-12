resource "helm_release" "jupyter_helm" {
  name       = "jupyterhub"
  repository = "https://jupyterhub.github.io/helm-chart"
  chart      = "jupyterhub"
  namespace  = "jhub-${var.tenant_identifier}"
  version    = "1.2.0"

  cleanup_on_fail  = true
  create_namespace = true

  values = [
    templatefile("${path.module}/jupyter_config.yaml", {
      cognito_oauth_base_url = var.cognito_oauth_base_url
      oauth_client_id        = aws_cognito_user_pool_client.jupyter_cognito_client.id
      oauth_client_secret    = aws_cognito_user_pool_client.jupyter_cognito_client.client_secret
      jupyter_base_path      = local.jupyter_base_path
      jupyter_base_url       = local.jupyter_base_url
      jupyter_proxy_port     = var.jupyter_proxy_port
      shared_volume_name     = "${kubernetes_persistent_volume.dev_support_shared_volume.metadata.0.name}"
      kube2iam_role_arn      = "${aws_iam_role.jupyter_node_role.arn}"
    })
  ]

  # Need to wait for ALB to get created
  depends_on = [ aws_lb.jupyter_alb, helm_release.kube2iam_helm ]
}
