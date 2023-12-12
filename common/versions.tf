terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Limit version to get around this bug:
      # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2635
      # Can upgrade whenterraform-aws-eks > 20.0.0 is release
      version = "< 5.0.0"
    }
  }
  required_version = ">= 0.14"
}
