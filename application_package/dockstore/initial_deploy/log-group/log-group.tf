locals {
  name = "awsLogGroupDockstoreStack"
}

resource "aws_cloudformation_stack" "log_group" {
  name = local.name

  parameters = {
    LogGroupName = "/DeploymentConfig/${var.resource_prefix}/DomainName"
    CloudTrailLogGroupName = "/DeploymentConfig/${var.resource_prefix}/CloudTrailLogGroupName"

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

  template_body = file("${path.module}/log-group.yml")

}
