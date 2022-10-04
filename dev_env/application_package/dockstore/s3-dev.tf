resource "aws_cloudformation_stack" "s3" {
  name = "awsS3DockstoreStack"


  template_body = file("./s3-dev.yml")

}
