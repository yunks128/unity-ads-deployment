resource "aws_cloudformation_stack" "core" {
  name = "awsCoreDockstoreStack"

  parameters = {
    RestApiId = "${var.api_id}"
    TopParentId = "${var.api_parent_id}"
    ResourcePrefix = "${var.resource_prefix}"
    WebhookQueueName = "/DeploymentConfig/${var.resource_prefix}/WebhookQueueName"
    DeadQueueName = "/DeploymentConfig/${var.resource_prefix}/DeadQueueName"
    WAFLogsBucketName = "uads-${var.resource_prefix}-waf-logs-dockstore"
  }


  template_body = file("./core-dev.yml")
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_IAM"]
  timeout_in_minutes = 10

}



resource "aws_api_gateway_deployment" "ApiRedeploy" {
  rest_api_id = "${var.api_id}"
  stage_name  = "${var.resource_prefix}"

  lifecycle {
    create_before_destroy = true
  }
}


