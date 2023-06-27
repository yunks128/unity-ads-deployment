locals {
  name = "awsEsDockstoreStack"
}

resource "aws_cloudformation_stack" "es" {
  name = local.name

  parameters = {
    DomainName = "${var.resource_prefix}-dockstore-elasticsearch"
    VpcId = data.aws_vpc.unity_vpc.id
    SubnetId = tolist(data.aws_subnets.unity_private_subnets.ids)[0]

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

  template_body = file("${path.module}/elasticsearch.yml")

  timeouts {
    create = "1h"
    update = "1h"
    delete = "1h"
  }

  /* timeout_in_minutes = 60 */
}

