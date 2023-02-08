<!-- Header block for project -->
<hr>

<div align="center">

<!-- ☝️ Replace with your logo (if applicable) via ![](https://uri-to-your-logo-image) ☝️ -->
<!-- ☝️ If you see logo rendering errors, make sure you're not using indentation, or try an HTML IMG tag -->

<h1 align="center">U-ADS Deployment</h1>
<!-- ☝️ Replace with your repo name ☝️ -->

</div>

<pre align="center">Terraform based deployment of the U-ADS infrastructure into MCP-AWS</pre>

<!-- Header block for project -->

<!-- ☝️ Add badges via: https://shields.io e.g. ![](https://img.shields.io/github/your_chosen_action/your_org/your_repo) ☝️ -->

<!-- ☝️ Screenshot of your software (if applicable) via ![](https://uri-to-your-screenshot) ☝️ -->

This software encapsulates the deployment of the Unity Algorithm Development Services (U-ADS) infrastructure into an MCP AWS enclave. It consists of Terraform scripts for multiple services.

<!-- example links>
[Website](INSERT WEBSITE LINK HERE) | [Docs/Wiki](INSERT DOCS/WIKI SITE LINK HERE) | [Discussion Board](INSERT DISCUSSION BOARD LINK HERE) | [Issue Tracker](INSERT ISSUE TRACKER LINK HERE)
-->

## Features

Deploys these Unity ADS services:

* Development Environment
	* Jupyterlab
	* Shared Storage
	* EC2 Support Instance

  
## Development Environment

For each deployment instance (ie. development, test, production) define the following environment variables to customize the install to the environment. For example for the test deployment you would defined the following variables:

```
export TF_VAR_api_id=value1
export TF_VAR_api_parent_id=value2
export TF_VAR_resource_refix=dev
export TF_VAR_availability_zone=us-west-2b

# Do not worry about populating these correctly for infrastructure/initial deploy
export TF_VAR_dockstore_token=""
```

The `resource_prefix` should match the environment you are deploying in (one of `dev`, `test`, or `prod`).

The `api_id` value should be the ID assigned to the `Unity API Gateway`. 

The `api_parent_id` value should be the ID assigned to the desired parent resource for the new dockstore method in `Unity API Gateway` - currently we are using `/ads`. Both ID values are acccessible through `AWS Console: API Gateway -> Unity API Gateway` where upper toolbar lists the ID values: `APIs > Unity API Gateway (value1) > Resources > /ads (value2)`

The `availability_zone` should be the availability zone requested for the DB and other resources - should match available subnets availability zones.

The `dockstore_token` is the Dockstore administrator account token accessible from the Dockstore user account once the Dockstore application is deployed and user is registered with the application. Please note that `dockstore_token` cannot be set until after the Dockstore application has been deployed in the second (out of three) terraform deployment. It is the token associated with the `admin` account that will be used for the GitHub Lambda authentication.


### Initial Deployment 

The initial deployment consists of many resources required prior to deploying the actual application (Iam Roles and Privileges, DB, LoadBalancer, etc.). The steps are as follows:

1. Change to the `application_package/dockstore/initial_deploy/` directory
2. Download and copy the private key for the GitHub App that communicates with Dockstore into the `s3` subdirectory. It should be tarred and gzipped and have the name `dockstore-github-private-key.pem.tar.gz`
3. Run `terraform init`
4. Run `terraform apply`

### Application Deployment

There is a GitHub app that talks to the GitHub Lambda, which will be deployed later in the instruction set. It needs proper URLs for the WebHook, Callback, and Homepage settings. The WebHook URL should not change frequently, as it is dependent on the API Gateway in the AWS env and pre-defined resources within it, and the API Gateway is pretty static. The Callback and Homepage settings should follow the convention ``<LOAD_BALANCER_DNS_NAME>:9998/` where `<LOAD_BALANCER_DNS_NAME>` is the output LB DNS name from the Load Balancer Stack created in the initial deployment. Each env requires a separate app, and currently the app for dev is https://github.com/apps/jpl-uads-dockstore-dev-1 and the app for test is https://github.com/apps/jpl-uads-dockstore .


### Application Deployment

The Dockstore application is installed within an EC2 instance and the second deployment handles standing it up. The steps are as follows:
 
1. Change to the `application_package/dockstore/app_deploy/app/` directory (relative to `application_package/dockstore/initial_deploy/` it is `../app_deploy/app/`)
2. Run `terraform init`
3. Run `terraform apply`

### User Account

The lambda deployment requires an admin user's Dockstore token for authentication. To create this:

1. Register a user - currently only able to do this with public GitHub credentials
2. Updare the database to make the user an admin
3. Grab the token from the account info on the Dockstore webpage or the database and set the env var `TF_VAR_dockstore_token` with the value

### Application Deployment

The final step is the GitHub Lambda deployment. The steps are as follows:

1. Change to the `application_package/dockstore/app_deploy/lambda/` directory (relative to `application_package/dockstore//app_deploy/app/` it is `../lambda/``)
2. Run `terraform init`
3. Run `terraform apply`
4. Update the loadbalancer URL in the env.json file of the lambda via the AWS Web UI.

The EC2 instance that the application is run on can be connected to via SSM either in the AWS Web UI or wsing the `aws ssm` CLI command. You can connect in order to debug any issues with the application, and it is the only location from which you can connect to the RDS/Database instace.


