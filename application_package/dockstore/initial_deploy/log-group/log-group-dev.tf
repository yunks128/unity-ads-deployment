
resource "aws_cloudformation_stack" "log_group" {
  name = "awsLogGroupDockstoreStack"

  parameters = {
    LogGroupName = "/DeploymentConfig/${var.resource_prefix}/DomainName"
    CloudTrailLogGroupName = "/DeploymentConfig/${var.resource_prefix}/CloudTrailLogGroupName"
     
  }

  template_body = file("${path.module}/log-group-dev.yml")

}




