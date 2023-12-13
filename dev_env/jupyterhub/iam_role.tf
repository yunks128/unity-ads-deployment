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
      },
      {
        "Action": "sts:AssumeRole",
        "Principal": { "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
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
                "arn:aws:s3:::uds-${var.s3_identifier}-cumulus-private",
                "arn:aws:s3:::uds-${var.s3_identifier}-cumulus-protected",
                "arn:aws:s3:::uds-${var.s3_identifier}-cumulus-public",
                "arn:aws:s3:::uds-${var.s3_identifier}-cumulus-protected/*",
                "arn:aws:s3:::uds-${var.s3_identifier}-cumulus-private/*",
                "arn:aws:s3:::uds-${var.s3_identifier}-cumulus-public/*"
            ]
        }
      ]
   })

}

resource "aws_iam_role_policy_attachment" "jupyter_node_attach" {
  role       = aws_iam_role.jupyter_node_role.name
  policy_arn = aws_iam_policy.jupyter_node_policy.arn
}
