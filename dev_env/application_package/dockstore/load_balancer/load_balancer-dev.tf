resource "aws_cloudformation_stack" "dev" {
  name = "awsDevDockstoreStack"


  template_body = file("./load_balancer-dev.yml")

}

