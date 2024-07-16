variable "project" {
  description = "The name of the project matching the /unity/<{project>/<venue</project-name SSM parameter"
  type        = string
  default     = "unity"
}

variable "venue" {
  description = "The name of the unity venue matching the /unity/<project>/<venue>/venue-name SSM parameter"
  type        = string
}

variable "venue_prefix" {
  description = "Optional string to place before the venue name in resource names"
  type        = string
  default     = ""
}

variable "resource_prefix" {
  description = "String used at the beginning of the names for all resources to identify them according to the UADS subsystem"
  type        = string
  default     = "uads"
}

variable "efs_identifier" {
  description = "EFS file system to connect Jupyter shared storage with"
  type        = string
  # Example value:uads-development-efs-fs"
}

# These are for validation of the input variables
data "aws_ssm_parameter" "project" {
  name = "/unity/${var.project}/${var.venue}/project-name"

  lifecycle {
    postcondition {
      condition     = self.value == var.project
      error_message = "project variable value ${var.project} does not match SSM parameter value in /unity/${var.project}/${var.venue}/project-name: {$data.aws_ssm_parameter.project}"
    }
  }
}

data "aws_ssm_parameter" "venue" {
  name = "/unity/${var.project}/${var.venue}/venue-name"

  lifecycle {
    postcondition {
      condition    = self.value == var.venue
      error_message = "venue variable value ${var.venue} does not match SSM parameter value in /unity/${var.project}/${var.venue}/venue-name: {$data.aws_ssm_parameter.venue}"
    }
  }
}
