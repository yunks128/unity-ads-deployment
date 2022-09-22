data "aws_caller_identity" "current" {
}

resource "aws_iam_role" "eks_cluster_role" {
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  description          = "Allows access to other AWS service resources that are required to operate clusters managed by EKS for tenant ${var.tenant_identifier}."
  managed_policy_arns  = [ "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" ]
  max_session_duration = "3600"
  name                 = "Unity-ADS-${var.tenant_identifier}-EKSClusterRole"
  path                 = "/"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"
}


resource "aws_iam_role" "jupyter_node_role" {
  name = "Unity-ADS-${var.tenant_identifier}-JupyterNodeRole"

  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "s3.amazonaws.com"
        },
        "Effect": "Allow",
      }
    ]
  })
  
}

resource "aws_iam_policy" "jupyter_node_policy" {
  name = "Unity-ADS-${var.tenant_identifier}-JupyterNodePolicy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": [
                "arn:aws:s3:::uds-dev-cumulus-private",
                "arn:aws:s3:::uds-dev-cumulus-protected",
                "arn:aws:s3:::uds-dev-cumulus-public",
                "arn:aws:s3:::uds-dev-cumulus-protected/*",
                "arn:aws:s3:::uds-dev-cumulus-private/*",
                "arn:aws:s3:::uds-dev-cumulus-public/*"
            ]
        }
      ]
   })

}

resource "aws_iam_role_policy_attachment" "jupyter_node_attach" {
  role       = aws_iam_role.jupyter_node_role.name
  policy_arn = aws_iam_policy.jupyter_node_policy.arn
}

resource "aws_iam_role" "eks_node_role" {
  name                 = "Unity-ADS-${var.tenant_identifier}-EKSNodeRole"
  path                 = "/"
  description          = "Allows EKS node EC2 instances to call AWS services on behalf of tenant ${var.tenant_identifier}."

  managed_policy_arns  = [ "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", 
                           "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
                           "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
                           "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
                           "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
                           "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/DatalakeKinesisPolicy",
                           "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/McpToolsAccessPolicy" ]

  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      },
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "${aws_iam_role.jupyter_node_role.arn}"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

}
