resource "aws_cloudformation_stack" "dev" {
  name = "awsLBDockstoreStack"

  parameters = {
    ResourcePrefix = "${var.resource_prefix}"
    VpcId = data.aws_vpc.unity_vpc.id
    SubnetId1 = tolist(data.aws_subnets.unity_public_subnets.ids)[0]
    SubnetId2 = tolist(data.aws_subnets.unity_public_subnets.ids)[1]
    S3Stack = "awsS3DockstoreStack"
    LBLogsS3BucketName = "${var.lb_logs_bucket_name}"
    LBLogsS3BucketPrefix = "${var.lb_logs_bucket_prefix}"
  }

  template_body = file("${path.module}/load_balancer.yml")

}



