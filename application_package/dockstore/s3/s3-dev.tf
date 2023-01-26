resource "aws_cloudformation_stack" "s3" {
  name = "awsS3DockstoreStack"


  parameters = {
    ResourcePrefix = "${var.resource_prefix}"
    ELBLogsBucketName = "uads-${var.resource_prefix}-dockstore-elb-logs"
    BucketName = "uads-${var.resource_prefix}-dockstore-startup"
  }


  template_body = file("./s3-dev.yml")
  iam_role_arn = "arn:aws:iam::237868187491:role/uads-dockstore-cf-role"
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_IAM"]

}
