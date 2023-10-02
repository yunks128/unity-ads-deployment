locals {
  name = "awsDbDockstoreStack"
}
resource "aws_cloudformation_stack" "db" {
  name = local.name

  parameters = {
    ResourcePrefix = "${var.resource_prefix}"
    DBName = "${var.resource_prefix}"
    DBMasterUserPassword  = "/DeploymentConfig/${var.resource_prefix}/DBPostgresPassword"
    DBSnapshot = "${var.db_snapshot}"
    VpcId = "${var.unity_vpc}"
    /* SubnetId1 = tolist(data.aws_subnets.unity_public_subnets.ids)[0]
    SubnetId2 = tolist(data.aws_subnets.unity_public_subnets.ids)[1] */
    SubnetId1 = "${var.subnet_id1}"
    SubnetId2 = "${var.subnet_id2}"

    AvailabilityZone = "${var.availability_zone_1}"

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

  template_body = file("${path.module}/database.yml")

  timeouts {
    create = "1h"
    update = "1h"
    delete = "1h"
  }
}
