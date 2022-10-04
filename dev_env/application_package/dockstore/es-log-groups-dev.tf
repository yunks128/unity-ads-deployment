resource "aws_cloudformation_stack" "es_log_groups" {
  name = "awsEsLogGroupsDockstoreStack"


  template_body = file("./es-log-groups-dev.yml")

}

