locals {
  common_tags = {
    Proj = "unity"
    Venue = "${var.resource_prefix}"
    Component = "dockstore"
    CreatedBy = "ads"
    ServiceArea = "ads"
    Env = "${var.resource_prefix}"
    Stack = "dockstore"
  }
}
