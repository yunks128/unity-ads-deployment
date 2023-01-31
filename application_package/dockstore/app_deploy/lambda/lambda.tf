resource "aws_cloudformation_stack" "dockstore_app_lambda" {
  name = "awsAppLambdaDockstoreStack"

  parameters = {
    DockstoreLambdaBucket = "uads-${var.resource_prefix}-dockstore-lambda-bucket"
    DockstoreToken = "${var.dockstore_token}"
    DockstoreApiUrl = "${var.dockstore_api_url}"

    #These inputs are AWS Session Manager Parameter Store paths
    SecretToken = "/DeploymentConfig/${var.resource_prefix}/SecretToken"
  }

  template_body = file("./dockstore-app.yml")
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_IAM"]
}

