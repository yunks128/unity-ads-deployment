


variable "dockstore_api_url" {
  description = "The fully qualified base url for the Dockstore API trailing slash required, e.g., https://.dockstore.net/api/"
  type = string
}

variable "dockstore_token" {
  description = "The Dockstore token used by the lambda to make API calls to Dockstore"
  type = string
}





