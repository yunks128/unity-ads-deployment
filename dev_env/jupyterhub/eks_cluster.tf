data "aws_caller_identity" "current" {
}

data "aws_ssm_parameter" "ami_id" {
  name = "/mcp/amis/aml2-eks-1-30"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${var.resource_prefix}-${var.venue_prefix}${var.venue}-jupyter"
  cluster_version = "1.30"

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  subnet_ids       = local.subnet_map["private"]

  vpc_id = data.aws_ssm_parameter.vpc_id.value

  enable_irsa = true

  create_iam_role = true
  iam_role_name = "Unity-ADS-${var.venue_prefix}${var.venue}-EKSClusterRole"
  iam_role_permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"

  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    create_iam_role = true
    iam_role_name = "Unity-ADS-${var.venue_prefix}${var.venue}-EKSNodeRole"
    iam_role_permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"

    ami_id          = data.aws_ssm_parameter.ami_id.value

    # This seemes necessary so that MCP EKS ami images can communicate with the EKS cluster
    enable_bootstrap_user_data = true
    pre_bootstrap_user_data = <<-EOT
      sudo sed -i 's/^net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/' /etc/sysctl.conf && sudo sysctl -p |true
    EOT

    # Ensure that cost tags are applied to dynamically allocated resources
    launch_template_tags = local.cost_tags
  }

  eks_managed_node_groups = {
    jupyter = {
      instance_types = var.eks_node_instance_types
      disk_size      = var.eks_node_disk_size
      min_size       = var.eks_node_min_size
      max_size       = var.eks_node_max_size
      desired_size   = var.eks_node_desired_size
    }
  }

}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}
