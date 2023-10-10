#!/usr/bin/env bash

# Uses AWS to extract information to feed to the Jupyter stage as variables for setting up the connection to cognito
# terraform apply must have already been run

script_dir=$(dirname $0)
cd $script_dir

if [ -z "$(which terraform 2>/dev/null)" ]; then
    echo "ERROR: terraform CLI is not installed"
    exit 1
fi

if [ -z "$(which aws 2>/dev/null)" ]; then
    echo "ERROR: aws CLI is not installed"
    exit 1
fi

# Parse information from terraform
tf_output=$(terraform output -json)

if [ -z "$tf_output" ]; then
    echo "No Terraform output from call to call"
    exit 1
fi

user_pool_id=$(echo $tf_output | jq -r .cognito_user_pool_id.value)

if [ -z "$user_pool_id" ]; then
    echo "No Cognito user pool id parsed from terraform output"
    exit 1
fi

client_id=$(echo $tf_output | jq -r .cognito_client_id.value)

if [ -z "$client_id" ]; then
    echo "No Cognito client id parsed from terraform output"
    exit 1
fi

# Collect information about the user pool
user_pool_info=$(aws cognito-idp describe-user-pool --user-pool-id "$user_pool_id")

if [ -z "$user_pool_info" ]; then
    echo "No information returned about user pool with id $user_pool_id"
    exit 1
fi

aws_region=$(echo $user_pool_info | jq -r '.UserPool.Arn' | awk -F ':' '{print $4}')

if [ -z "$aws_region" ]; then
    echo "No aws region parsed from user pool information"
    exit 1
fi

domain=$(echo $user_pool_info | jq -r '.UserPool.Domain')

if [ -z "$domain" ]; then
    echo "No domain name parsed from user pool information"
    exit 1
fi

# Obtain client information

# Collect information about the user pool
client_info=$(aws cognito-idp describe-user-pool-client --user-pool-id "$user_pool_id" --client-id "$client_id")

if [ -z "$client_info" ]; then
    echo "No information returned about user pool client with user pool id $user_pool_id and client id $client_id"
    exit 1
fi

client_secret=$(echo $client_info | jq -r .UserPoolClient.ClientSecret)

# Print out configuration variables
echo "export TF_VAR_cognito_oauth_base_url=\"https://${domain}.auth.${aws_region}.amazoncognito.com\""
echo "export TF_VAR_cognito_oauth_client_id=\"${client_id}\""
echo "export TF_VAR_cognito_oauth_client_secret=\"${client_secret}\""
