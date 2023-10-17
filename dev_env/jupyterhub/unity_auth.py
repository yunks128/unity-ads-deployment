"""
Unity JupyterHub Custom OAuthenticator to capture and pass Cognito tokens.client_id
This code is implemented based on https://oauthenticator.readthedocs.io/en/latest/writing-an-oauthenticator.html
"""
import json
import base64
import jwt
import time
import sys
import hmac
import hashlib

from jupyterhub.auth import LocalAuthenticator
from tornado.httpclient import AsyncHTTPClient, HTTPError, HTTPRequest
from tornado.httputil import url_concat
from datetime import datetime
from oauthenticator.oauth2 import OAuthenticator, OAuthLoginHandler

class UnityOAuthenticator(OAuthenticator):

    # login_service is the text displayed on the "Login with..." button
    login_service = "Unity Common Services"

    access_token = ""
    id_token = ""
    refresh_token = ""
    access_token_expires_in = 0
    app_client_id = ""
    secret_hash = ""

    # Authenticates the user with Cognito
    async def authenticate(self, handler, data=None):
        # Exchange the OAuth code for an Access Token
        code = handler.get_argument("code")
        http_client = AsyncHTTPClient()

        # Encode client Id and secret
        message = self.client_id + ":" + self.client_secret
        message_bytes = message.encode('ascii')
        base64_bytes = base64.b64encode(message_bytes)
        base64_auth = base64_bytes.decode('ascii')

        params = dict(
            client_id=self.client_id, code=code, grant_type="authorization_code", redirect_uri=self.oauth_callback_url
        )

        url = url_concat(self.token_url, params)

        req = HTTPRequest(
            url, method="POST", headers={"Accept": "application/json", "Authorization":"Basic " + base64_auth, "Content-Type":"application/x-www-form-urlencoded"}, body=''
        )

        resp = await http_client.fetch(req)
        resp_json = json.loads(resp.body.decode('utf8', 'replace'))

        if 'access_token' in resp_json:
            global access_token
            access_token = resp_json['access_token']
            global id_token
            id_token = resp_json['id_token']
            global refresh_token
            refresh_token = resp_json['refresh_token']
            global access_token_expires_in
            access_token_expires_in = resp_json['expires_in']

        elif 'error_description' in resp_json:
            raise HTTPError(
                403,
                f"An access token was not returned: {resp_json['error_description']}",
            )
        else:
            raise HTTPError(500, f"Bad response: {resp}")

        req = HTTPRequest(
            self.userdata_url,
            method="GET",
            headers={"Authorization": f"Bearer {access_token}"},
        )

        resp = await http_client.fetch(req)
        resp_json = json.loads(resp.body.decode('utf8', 'replace'))

        username = resp_json["username"]

        if not username:
            # No user is authenticated and login has failed
            return None

        # Calculate secret hash and obtain other variables required to refresh tokens later
        global app_client_id
        app_client_id = self.client_id
        key = self.client_secret
        message = bytes(username + app_client_id,'utf-8')
        key = bytes(key,'utf-8')
        global secret_hash
        secret_hash = base64.b64encode(hmac.new(key, message, digestmod=hashlib.sha256).digest()).decode()

        return {
            'name': username,
            'auth_state': {
                'access_token': access_token,
                'id_token': id_token,
                'refresh_token': refresh_token,
                'access_token_expires_in': access_token_expires_in,
            },
        }

c.JupyterHub.authenticator_class = UnityOAuthenticator

# Sets Cognito specific environment variables in the JupyterLab during the spawn
def modify_pod_hook(spawner, pod):

  global access_token
  pod.spec.containers[0].env.append({"name": "UNITY_COGNITO_ACCESS_TOKEN", "value": access_token})

  global id_token
  pod.spec.containers[0].env.append({"name": "UNITY_COGNITO_ID_TOKEN", "value": id_token})

  global refresh_token
  pod.spec.containers[0].env.append({"name": "UNITY_COGNITO_REFRESH_TOKEN", "value": refresh_token})

  global access_token_expires_in
  epoch_seconds = int(time.time())
  cognito_access_token_expiry = str(access_token_expires_in + epoch_seconds)
  pod.spec.containers[0].env.append({"name": "UNITY_COGNITO_ACCESS_TOKEN_EXPIRY", "value": cognito_access_token_expiry})

  global app_client_id
  pod.spec.containers[0].env.append({"name": "UNITY_COGNITO_APP_CLIENT_ID", "value": app_client_id})

  global secret_hash
  pod.spec.containers[0].env.append({"name": "UNITY_COGNITO_SECRET_HASH", "value": secret_hash})

  return pod

c.KubeSpawner.modify_pod_hook = modify_pod_hook
