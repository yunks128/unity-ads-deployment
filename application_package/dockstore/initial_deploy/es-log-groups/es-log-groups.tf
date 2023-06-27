locals {
  name = "awsEsLogGroupsDockstoreStack"
}

resource "aws_cloudformation_stack" "es_log_groups" {
  name = local.name

  parameters = {
    LogGroupName = "/aws/aes/domains/${var.resource_prefix}-dockstore-elasticsearch/application-logs"

    # Tags to pass to the CloudFormation resources
    ServiceArea = local.common_tags.ServiceArea
    Proj = local.common_tags.Proj
    Venue = local.common_tags.Venue
    Component = local.common_tags.Component
    CreatedBy = local.common_tags.CreatedBy
    Env = local.common_tags.Env
    Stack = local.common_tags.Stack
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.name
    }
  )

  template_body = file("${path.module}/es-log-groups.yml")
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
