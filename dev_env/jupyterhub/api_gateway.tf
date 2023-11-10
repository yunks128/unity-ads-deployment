variable "api_gateway_name" {
  description = "Name of the API gateway to connect proxies with to search for as an existing resource"
  type        = string
  default     = "Unity API Gateway"
}

variable "api_gateway_path_to_ads" {
  description = "Prefix of the Unity ADS portion of the API Gateway URL namespace to search for an existing resource"
  type        = string
  default     = "/ads"
}

variable "api_gateway_stage_name" {
  description = "Name of the deployed API gateway stage"
  type        = string
  default     = "dev"
}

data "aws_api_gateway_rest_api" "unity_api_gateway" {
  name = var.api_gateway_name
}

######
# VPC Link to Jupyter NLB

resource "aws_api_gateway_vpc_link" "api_lb_link" {
  name        = "jupyter-${var.tenant_identifier}-vpc-link"
  description = "VPC Link to ${var.tenant_identifier} Jupyter NLB"
  target_arns = [aws_lb.jupyter_nlb.arn]

  # Need to wait for NLB
  depends_on = [
    aws_lb.jupyter_nlb
  ]
}

######
# Base path /ads/jupyter

data "aws_api_gateway_resource" "api_resource_ads" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  path        = var.api_gateway_path_to_ads
}

resource "aws_api_gateway_resource" "api_resource_jupyter" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  parent_id   = data.aws_api_gateway_resource.api_resource_ads.id
  path_part   = "jupyter"
}

######
# Redirection of base URL /ads/jupyter

# create the method GET and assign it to the resource /jupyter
resource "aws_api_gateway_method" "api_method_base" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  resource_id = aws_api_gateway_resource.api_resource_jupyter.id

  http_method   = "GET"
  authorization = "NONE"
}

# create the mock integration which will returns the statusCode 301 on the previous method GET of the /jupyter
resource "aws_api_gateway_integration" "api_integration_base" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  resource_id = aws_api_gateway_resource.api_resource_jupyter.id

  http_method = aws_api_gateway_method.api_method_base.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" : "{ \"statusCode\": 301 }"
  }
}

# create the method response and enable the header Location
resource "aws_api_gateway_method_response" "api_response_base_301" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  resource_id = aws_api_gateway_resource.api_resource_jupyter.id

  http_method = aws_api_gateway_method.api_method_base.http_method
  status_code = "301"

  response_parameters = {
    "method.response.header.Location" : true
  }
}

# Fill the previous header with the destination. Notice the syntax of the location with single quotes wrapped by doubles.
resource "aws_api_gateway_integration_response" "api_response_redirect" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  resource_id = aws_api_gateway_resource.api_resource_jupyter.id

  http_method = aws_api_gateway_method.api_method_base.http_method
  status_code = aws_api_gateway_method_response.api_response_base_301.status_code

  response_parameters = {
    "method.response.header.Location" : "'/${local.jupyter_base_path}/hub/'"
  }
}

######
# Directly handle / so that we avoid redirect loop

resource "aws_api_gateway_resource" "api_resource_hub" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  parent_id   = aws_api_gateway_resource.api_resource_jupyter.id
  path_part   = "hub"
}

resource "aws_api_gateway_method" "api_method_hub" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  resource_id = aws_api_gateway_resource.api_resource_hub.id

  http_method      = "ANY"

  api_key_required = "false"
  authorization    = "NONE"
}

# proxying of end point to the nlb 
resource "aws_api_gateway_integration" "api_integration_hub" {
  rest_api_id             = data.aws_api_gateway_rest_api.unity_api_gateway.id
  resource_id             = aws_api_gateway_resource.api_resource_hub.id

  http_method             = "ANY"
  integration_http_method = "ANY"

  type                    = "HTTP_PROXY"
  uri                     = "${local.jupyter_proxy_dest}/hub/"

  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.api_lb_link.id

  # need to wait for alb 
  depends_on = [
    aws_lb.jupyter_nlb
  ]
}

######
# Proxy resources

resource "aws_api_gateway_resource" "api_resource_proxy" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  parent_id   = aws_api_gateway_resource.api_resource_jupyter.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "api_method_proxy" {
  rest_api_id = data.aws_api_gateway_rest_api.unity_api_gateway.id
  resource_id = aws_api_gateway_resource.api_resource_proxy.id

  http_method      = "ANY"

  api_key_required = "false"
  authorization    = "NONE"

  request_parameters = {
    "method.request.path.proxy" = "true"
  }

}

# proxying of end point to the nlb 
resource "aws_api_gateway_integration" "api_integration_proxy" {
  rest_api_id             = data.aws_api_gateway_rest_api.unity_api_gateway.id
  resource_id             = aws_api_gateway_resource.api_resource_proxy.id

  http_method             = "ANY"
  integration_http_method = "ANY"

  type                    = "HTTP_PROXY"
  uri                     = "${local.jupyter_proxy_dest}/{proxy}"

  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.api_lb_link.id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  # need to wait for alb 
  depends_on = [
    aws_lb.jupyter_nlb,
    aws_api_gateway_vpc_link.api_lb_link
  ]
}

######
# Deployment

resource "aws_api_gateway_deployment" "jupyter_api_deployment" {
  stage_name    = var.api_gateway_stage_name
  rest_api_id   = data.aws_api_gateway_rest_api.unity_api_gateway.id

  depends_on = [ 
    aws_api_gateway_integration.api_integration_proxy, 
    aws_api_gateway_integration.api_integration_hub
  ]
}

######
# Variables

locals {
  jupyter_base_url = "${aws_api_gateway_deployment.jupyter_api_deployment.invoke_url}${aws_api_gateway_resource.api_resource_jupyter.path}"
}

locals {
  jupyter_base_path = "${var.api_gateway_stage_name}${aws_api_gateway_resource.api_resource_jupyter.path}"
}

locals {
  jupyter_proxy_dest = "http://${aws_lb.jupyter_nlb.dns_name}:${aws_lb_listener.jupyter_nlb_listener.port}/${local.jupyter_base_path}"
}

output "jupyter_base_path" {
  value = local.jupyter_base_path
}

output "jupyter_base_url" {
  value = local.jupyter_base_url
}
