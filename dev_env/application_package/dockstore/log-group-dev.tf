resource "aws_cloudformation_stack" "log_group" {
  name = "awsLogGroupDockstoreStack"


  template_body = file("./log-group-dev.yml")

}
