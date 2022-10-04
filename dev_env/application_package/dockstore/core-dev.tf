resource "aws_cloudformation_stack" "core" {
  name = "awsCoreDockstoreStack"


  template_body = file("./core-dev.yml")


}

