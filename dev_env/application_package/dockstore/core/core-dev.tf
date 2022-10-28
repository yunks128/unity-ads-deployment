resource "aws_cloudformation_stack" "core" {
  name = "awsCoreDockstoreStack"


  template_body = file("./core-dev.yml")
  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_IAM"]
  timeout_in_minutes = 10

}

