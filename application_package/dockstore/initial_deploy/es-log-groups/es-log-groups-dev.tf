resource "aws_cloudformation_stack" "es_log_groups" {
  name = "awsEsLogGroupsDockstoreStack"


  parameters = {
    LogGroupName = "/aws/aes/domains/${var.resource_prefix}-dockstore-elasticsearch/application-logs"
  }

  template_body = file("${path.module}/es-log-groups-dev.yml")

}

data "aws_iam_policy_document" "dockstore-elasticsearch-application-logs" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]

    resources = ["arn:aws:logs:*"]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "elasticsearch-log-publishing-policy" {
  policy_document = data.aws_iam_policy_document.dockstore-elasticsearch-application-logs.json
  policy_name     = "dockstore-elasticsearch-application-logs"
}


