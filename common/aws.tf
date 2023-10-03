provider "aws" {
  default_tags {
    tags = {
      ServiceArea = "аds"
      Proj = "unity"
      Venue = "${var.resource_prefix}"
      Component = "${var.component_cost_name}"
      CreatedBy = "ads"
      Env = "${var.resource_prefix}"
      Stack = "${var.component_cost_name}"
    }
  }
}
