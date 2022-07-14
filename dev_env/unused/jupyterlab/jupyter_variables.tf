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
