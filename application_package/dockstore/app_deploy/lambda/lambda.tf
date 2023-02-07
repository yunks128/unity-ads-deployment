resource "aws_cloudformation_stack" "dockstore_app_lambda" {
  name = "awsAppLambdaDockstoreStack"

  parameters = {
    DockstoreLambdaBucket = "uads-${var.resource_prefix}-dockstore-lambda-bucket"
    DockstoreToken = "${var.dockstore_token}"
    LoadBalancerStack = "awsLBDockstoreStack"
    CoreStack = "awsCoreDockstoreStack"

    #These inputs are AWS Session Manager Parameter Store paths
    SecretToken = "/DeploymentConfig/${var.resource_prefix}/SecretToken"
  }

  template_body = file("./lambda.yml")
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_IAM"]
}

