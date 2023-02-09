resource "aws_cloudformation_stack" "iam" {
  name = "awsIamDockstoreStack2"

  parameters = {
    ResourcePrefix = "${var.resource_prefix}"
  }

  template_body = file("${path.module}/iam.yml")
  capabilities = ["CAPABILITY_NAMED_IAM"]

}
