provider "aws" {
  default_tags {
    tags = {
      ServiceArea = "аds"
      Proj = "unity"
      Venue = "${var.resource_prefix}"
      Component = "dockstore"
      CreatedBy = "ads"
      Env = "${var.resource_prefix}"
      Stack = "dockstore"
    }
  }
}
