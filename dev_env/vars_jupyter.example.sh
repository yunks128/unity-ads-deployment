export AWS_PROFILE=mcp-venue-dev

export KUBE_CONFIG_PATH=$HOME/.kube/config

# Required to be set before beginning installation
export TF_VAR_tenant_identifier="example-dev"
export TF_VAR_efs_identifier="uads-venue-dev-efs-fs"

# Can be determined automatically during installation process or supplied ahead of time
export TF_VAR_cognito_oauth_base_url="https://unitysds.auth.us-west-2.amazoncognito.com"
export TF_VAR_cognito_oauth_client_id=""
export TF_VAR_cognito_oauth_client_secret=""

# Optional, these are Terraform arrays defined as strings, please follow the syntax in the
# examples below
#export TF_VAR_jupyter_s3_buckets='["bogus-bucket-name-1", "bogus-bucket-name-2"]'
#export TF_VAR_jupyter_admin_users='[]'
