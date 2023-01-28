resource "aws_cloudformation_stack" "db" {
  name = "awsDbDockstoreStack"

   parameters = {
    ResourcePrefix = "${var.resource_prefix}"
    DBName = "${var.resource_prefix}"
    DBMasterUserPassword  = "/DeploymentConfig/${var.resource_prefix}/DBPostgresPassword"
    VpcId = data.aws_vpc.unity_vpc.id
    SubnetId1 = tolist(data.aws_subnets.unity_public_subnets.ids)[0]
    SubnetId2 = tolist(data.aws_subnets.unity_public_subnets.ids)[1]
  }

  template_body = file("${path.module}/database-dev.yml")


}
