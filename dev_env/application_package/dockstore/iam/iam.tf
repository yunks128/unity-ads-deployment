resource "aws_cloudformation_stack" "iam" {
  name = "awsIamDockstoreStack"


  template_body = file("./iam.yml")
  capabilities = ["CAPABILITY_NAMED_IAM"]

}
