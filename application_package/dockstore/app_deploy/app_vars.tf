

variable "auto_update" {
  description = " Whether the webservice and UI should update themselves nightly."
  type    = bool
  default = false
}

variable "compose_setup_version" {
  description = "The name of a dockstore deploy git reference, used to find a deploy build in the deploy bucket"
  type        = string
  default     = "1.12.0-rc.1"
}

variable "dockstore_deploy_version" {
  description = "The name of a dockstore deploy git reference, used to find a deploy build in the deploy bucket"
  type        = string
  default     = "1.12.3"
}

variable "uiversion" {
  description = "The UI version; must be available via CloudFront"
  type        = string
  default     = "2.9.2-0210d0e"
}

variable "galaxy_plugin_version" {
  description = "Which version of galaxy to download from artifactory (e.g. 0.0.3). Leave blank if no version desired."
  type        = string
  default     = "0.0.7"
}

variable "app_url" {
  description = "Dockstore App URL"
  type        = string
}


