locals {
  name = "awsIamDockstoreStack2"
}

resource "aws_cloudformation_stack" "iam" {
  name = local.name

  parameters = {
    ResourcePrefix = "${var.resource_prefix}"

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

  template_body = file("${path.module}/iam.yml")
  capabilities = ["CAPABILITY_NAMED_IAM"]
}
