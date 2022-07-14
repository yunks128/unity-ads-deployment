data "aws_cognito_user_pools" "unity_user_pool" {
  name = var.cognito_user_pool_name
}

resource "aws_cognito_user_pool_client" "jupyter_cognito_client" {
  name          = "unity-ads-jupyter-${var.tenant_identifier}-client"
  user_pool_id  = tolist(data.aws_cognito_user_pools.unity_user_pool.ids)[0]

  callback_urls = ["${local.jupyter_base_url}/hub/oauth_callback"]
  logout_urls   = ["${local.jupyter_base_url}/hub/login/oauth_callback/logout"]

  generate_secret                               = true
  supported_identity_providers                  = ["COGNITO"]
  allowed_oauth_flows                           = ["code"]
  allowed_oauth_flows_user_pool_client          = true
  allowed_oauth_scopes                          = ["email", "openid", "profile"]
  enable_propagate_additional_user_context_data = "false"
  enable_token_revocation                       = "true"
  prevent_user_existence_errors                 = "ENABLED"
}
