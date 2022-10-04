resource "aws_cloudformation_stack" "es" {
  name = "awsEsDockstoreStack"


  template_body = file("./elasticsearch-dev.yml")

}

