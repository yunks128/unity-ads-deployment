resource "aws_cloudformation_stack" "db" {
  name = "awsDbDockstoreStack"


  template_body = file("./database-dev.yml")


}
