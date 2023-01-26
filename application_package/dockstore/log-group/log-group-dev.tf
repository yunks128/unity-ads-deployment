
resource "aws_cloudwatch_group" "cw_log_group" {
 name = "/aws/lambda/uads-${var.resource_prefix}-dockstore"

}

resource "aws_cloudformation_stack" "log_group" {
  name = "awsLogGroupDockstoreStack"

  parameters = {
    LogGroupName = "/DeploymentConfig/${var.resource_prefix}/DomainName"
    CloudTrailLogGroupName = "/DeploymentConfig/${var.resource_prefix}/CloudTrailLogGroupName"
     
  }

  template_body = file("./log-group-dev.yml")

}




