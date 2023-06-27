locals {
  name = "awsAppLambdaDockstoreStack"
}

resource "aws_cloudformation_stack" "dockstore_app_lambda" {
  name = "${local.name}"

  parameters = {
    DockstoreLambdaBucket = "uads-${var.resource_prefix}-dockstore-lambda-bucket"
    DockstoreToken = "${var.dockstore_token}"
    LoadBalancerStack = "awsLBDockstoreStack"
    CoreStack = "awsCoreDockstoreStack"

    #These inputs are AWS Session Manager Parameter Store paths
    SecretToken = "/DeploymentConfig/${var.resource_prefix}/SecretToken"

    # Tags to pass to the CloudFormation resources
    ServiceArea = local.common_tags.ServiceArea
    Proj = local.common_tags.Proj
    Venue = local.common_tags.Venue
    Component = local.common_tags.Component
    CreatedBy = local.common_tags.CreatedBy
    Env = local.common_tags.Env
    Stack = local.common_tags.Stack
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.name
    }
  )
  template_body = file("./lambda.yml")
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_IAM"]
}

