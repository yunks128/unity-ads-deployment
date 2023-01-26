resource "aws_cloudformation_stack" "es_log_groups" {
  name = "awsEsLogGroupsDockstoreStack"


  parameters = {
    LogGroupName = "/aws/aes/domains/${var.resource_prefix}-dockstore-elasticsearch/application-logs"
  }

  template_body = file("./es-log-groups-dev.yml")

}

