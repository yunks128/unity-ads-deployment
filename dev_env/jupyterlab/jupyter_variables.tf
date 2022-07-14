variable "load_balancer_port" {
  description = "Incoming port where load balancer will accept traffic"
  type       = number
  default    = 8000
}

# Should be an integer between 30000 and 32767
variable "jupyter_proxy_port" {
  description = "Listening port for Jupyter kubernetes cluster"
  type       = number
  default    = 32232
}

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

variable "api_gateway_invoke_url" {
  description = "Invoke URL for the API gateway"
  type        = string
}
