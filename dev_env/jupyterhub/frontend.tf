#####################
# Frontend selection
#
# Only one of the two choices below can be enabled at a time
# Run terraform init if changing between the two

###################################################################
# Use an API Gateway connected to a NLB as the Jupyterhub Frontend
# 
# This options mostly works except that websockets fail to properly
# be routed through the REST API gateway, more work would be needed
# to get it working.

# module "frontend" {
#   source = "./modules/api_gateway"
# 
#   tenant_identifier = var.tenant_identifier
#   resource_prefix = var.resource_prefix
#   load_balancer_port = var.load_balancer_port
#   jupyter_proxy_port = var.jupyter_proxy_port
# 
#   vpc_id = data.aws_ssm_parameter.vpc_id.value
#   lb_subnet_ids = local.subnet_map["private"]
#   security_group_id = aws_security_group.jupyter_lb_sg.id
#   autoscaling_group_name = module.eks.eks_managed_node_groups_autoscaling_group_names[0]
# }

#################################################################
# Use only a Application Load Balancer as the Jupyterhub Frontend

module "frontend" {
  source = "./modules/load_balancer"

  tenant_identifier = var.tenant_identifier
  resource_prefix = var.resource_prefix
  load_balancer_port = var.load_balancer_port
  jupyter_proxy_port = var.jupyter_proxy_port

  vpc_id = data.aws_ssm_parameter.vpc_id.value
  lb_subnet_ids = local.subnet_map["public"]
  security_group_id = aws_security_group.jupyter_lb_sg.id
  autoscaling_group_name = module.eks.eks_managed_node_groups_autoscaling_group_names[0]
}
