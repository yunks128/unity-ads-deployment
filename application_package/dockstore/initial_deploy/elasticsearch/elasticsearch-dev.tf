resource "aws_cloudformation_stack" "es" {
  name = "awsEsDockstoreStack"

  parameters = {
    ResourcePrefix = "${var.resource_prefix}"
    DomainName = "${var.resource_prefix}-dockstore-elasticsearch"
    VpcId = data.aws_vpc.unity_vpc.id
    SubnetId = tolist(data.aws_subnets.unity_private_subnets.ids)[0]
  }



  template_body = file("${path.module}/elasticsearch-dev.yml")

}

