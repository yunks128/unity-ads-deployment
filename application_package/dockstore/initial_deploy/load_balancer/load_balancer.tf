locals {
  name = "awsLBDockstoreStack"
}

resource "aws_cloudformation_stack" "env_resource" {
  name = local.name

  parameters = {
    ResourcePrefix = "${var.resource_prefix}"
    VpcId = data.aws_vpc.unity_vpc.id
    /* SubnetId1 = tolist(data.aws_subnets.unity_public_subnets.ids)[0]
    SubnetId2 = tolist(data.aws_subnets.unity_public_subnets.ids)[1] */
    SubnetId1 = local.unity_subnets["${var.availability_zone_1}"].public
    SubnetId2 = local.unity_subnets["${var.availability_zone_2}"].public

    S3Stack = "awsS3DockstoreStack"
    LBLogsS3BucketName = "${var.lb_logs_bucket_name}"
    LBLogsS3BucketPrefix = "${var.lb_logs_bucket_prefix}"

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

  template_body = file("${path.module}/load_balancer.yml")
}



