resource "aws_cloudformation_stack" "dev" {
  name = "awsDevDockstoreStack"


  template_body = file("./dockstore-dev_del.yml")

}

