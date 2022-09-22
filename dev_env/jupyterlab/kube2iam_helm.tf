resource "helm_release" "kube2iam_helm" {
  name       = "kube2iam"
  repository = "https://jtblin.github.io/kube2iam"
  chart      = "kube2iam"
  namespace  = "jhub-${var.tenant_identifier}"
  version    = "2.6.0"

  cleanup_on_fail  = true
  create_namespace = true

  values = [
    templatefile("${path.module}/kube2iam_config.yaml", {
    	base_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/"
	default_role  = "${aws_iam_role.jupyter_node_role.name}"
    })
  ]

  depends_on = []
}
