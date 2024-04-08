import os
import time
import boto3
import json

def get_unity_cognito_access_token():
    
    """
    Returns the Cognito access token. If the Cognito access token is expired, then this function uses the Cognito refresh token
    to refresh the environment variables: UNITY_COGNITO_ACCESS_TOKEN, UNITY_COGNITO_ID_TOKEN and UNITY_COGNITO_ACCESS_TOKEN_EXPIRY. 
    After renewing the environment variables, this fucntions returns the new Cognito access token.
    
    The environment variables UNITY_COGNITO_ACCESS_TOKEN_EXPIRY, UNITY_COGNITO_REFRESH_TOKEN, UNITY_COGNITO_SECRET_HASH, 
    UNITY_COGNITO_APP_CLIENT_ID and  UNITY_COGNITO_ACCESS_TOKEN should be available for this function to work. These environment variables
    are populated during the JupyterLab spawn.
    
    This function uses the Cognito refresh token and by default the Cognito refresh token will expire after 30 days. It was assumed that this JupyterLab
    will not stay active more more than 30 days. If this assumption is no longer valid in future, it is required to update this fucntion to update the environment 
    variable REFRESH_TOKEN_AUTH too using the client_idp.initiate_auth with USER_PASSWORD_AUTH auth flow. 
    
    The following link contains an example where user name and password is obtained from a user to execute the client_idp.initiate_auth with USER_PASSWORD_AUTH auth flow.
    https://github.com/unity-sds/unity-cs-security/blob/main/code_samples/jupyter/identity_pool_aws_creds/Cognito-Identity-Pool-S3-Access.ipynb
    """
    
    unity_cognito_access_token_expiry = int(os.environ.get('UNITY_COGNITO_ACCESS_TOKEN_EXPIRY'))
    current_epoch_seconds = int(time.time())

    # Check if the Cognito access token is expired
    if current_epoch_seconds > unity_cognito_access_token_expiry:
        # Get a new token
        client = boto3.client('cognito-idp', region_name='us-west-2')

        # Get tokens from Cognito using the refresh token
        response = client.initiate_auth(
            AuthFlow='REFRESH_TOKEN_AUTH',
            AuthParameters={
                'REFRESH_TOKEN': os.environ.get('UNITY_COGNITO_REFRESH_TOKEN'),
                'SECRET_HASH': os.environ.get('UNITY_COGNITO_SECRET_HASH')
            },
            ClientId = os.environ.get('UNITY_COGNITO_APP_CLIENT_ID')
        )

        access_token = response['AuthenticationResult']['AccessToken']
        id_token = response['AuthenticationResult']['IdToken']
        access_token_expiry = current_epoch_seconds + int(response['AuthenticationResult']['ExpiresIn'])

        os.environ["UNITY_COGNITO_ACCESS_TOKEN"] = str(access_token)
        os.environ["UNITY_COGNITO_ID_TOKEN"] = str(id_token)
        os.environ["UNITY_COGNITO_ACCESS_TOKEN_EXPIRY"] = str(access_token_expiry)
        
    return os.environ.get('UNITY_COGNITO_ACCESS_TOKEN')