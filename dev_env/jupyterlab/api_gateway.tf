data "aws_api_gateway_rest_api" "unity_api_gateway" {
  name = var.api_gateway_name
}

data "aws_api_gateway_resource" "api_resource_ads" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  path        = var.api_gateway_path_to_ads
}

resource "aws_api_gateway_resource" "api_resource_jupyter" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  parent_id   = data.aws_api_gateway_resource.api_resource_ads.id
  path_part   = "jupyter"
}

resource "aws_api_gateway_resource" "api_resource_proxy" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  parent_id   = aws_api_gateway_resource.api_resource_jupyter.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "api_gateway_method" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  resource_id = aws_api_gateway_resource.api_resource_proxy.id

  http_method      = "ANY"

  api_key_required = "false"
  authorization    = "NONE"

  request_parameters = {
    "method.request.path.proxy" = "true"
  }

}

resource "aws_api_gateway_vpc_link" "api_gateway_lb_link" {
  name        = "jupyter-${var.tenant_identifier}-vpc-link"
  description = "VPC Link to ${var.tenant_identifier} Jupytyer NLB"
  target_arns = [aws_lb.jupyter_nlb.arn]

  # Need to wait for NLB 
  depends_on = [
    aws_lb.jupyter_nlb
  ]
}

resource "aws_api_gateway_integration" "api_gateway_integration" {
  rest_api_id             = data.aws_api_gateway_rest_api.unity_api_gateway.id
  resource_id             = aws_api_gateway_resource.api_resource_proxy.id
  http_method             = "ANY"
  integration_http_method = "ANY"

  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.jupyter_nlb.dns_name}:${aws_lb_listener.jupyter_nlb_listener.port}${local.jupyter_api_path}/{proxy}"

  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.api_gateway_lb_link.id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

locals {
  jupyter_api_url = "${var.api_gateway_invoke_url}${aws_api_gateway_resource.api_resource_jupyter.path}"
}

locals {
  jupyter_api_path = format("/%s%s", basename(var.api_gateway_invoke_url), aws_api_gateway_resource.api_resource_jupyter.path)
}

output "jupyter_api_uri" {
  value = local.jupyter_api_url
}
