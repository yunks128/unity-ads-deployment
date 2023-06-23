locals {
  name = "awsCoreDockstoreStack"
}

resource "aws_cloudformation_stack" "core" {
  name = local.name

  parameters = {
    RestApiId = "${var.api_id}"
    TopParentId = "${var.api_parent_id}"
    ResourcePrefix = "${var.resource_prefix}"
    WebhookQueueName = "/DeploymentConfig/${var.resource_prefix}/WebhookQueueName"
    DeadQueueName = "/DeploymentConfig/${var.resource_prefix}/DeadQueueName"
    WAFLogsBucketName = "uads-${var.resource_prefix}-waf-logs-dockstore"

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

  template_body = file("${path.module}/core.yml")
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_IAM"]
  /* timeout_in_minutes = 60 */

  timeouts {
    create = "1h"
    update = "1h"
    delete = "1h"
  }
}

resource "aws_api_gateway_deployment" "ApiRedeploy" {
  rest_api_id = "${var.api_id}"
  stage_name  = "${var.resource_prefix}"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
        aws_cloudformation_stack.core
    ]
}


