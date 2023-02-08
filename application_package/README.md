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

  
## Setting up Development Environment

For each deployment instance (ie. development, test, production) define the following environment variables to customize the install to the environment. For example, for the `dev` (development) deployment you would defined the following variables:

```
export TF_VAR_resource_prefix=dev
export TF_VAR_api_id=value1
export TF_VAR_api_parent_id=value2
export TF_VAR_availability_zone=us-west-2b

# Do not worry about populating this token correctly for infrastructure/initial deploy (step #1 below)
export TF_VAR_dockstore_token=""
```

Where:

`resource_prefix` - one of `dev`, `test`, or `prod` and represents the environment is being deployed.

`api_id` - the ID assigned to the `Unity API Gateway`.

`api_parent_id` - the ID assigned to the desired parent resource for the new dockstore method in `Unity API Gateway` - currently we are using `/ads`. 

Note: Both ID values are accessible through `AWS Console: API Gateway -> Unity API Gateway` where upper toolbar lists the ID values: `APIs > Unity API Gateway (value1) > Resources > /ads (value2)`

`availability_zone` - the availability zone requested for the DB and other resources and should match available subnets availability zones.

`dockstore_token` - the Dockstore administrator account token that will be used for the GitHub Lambda authentication. The token is accessible from the Dockstore user account once the Dockstore application is deployed and administrator user is registered with the application. Please note that `dockstore_token` cannot be set until after the Dockstore application has been deployed in the `#2. Application Deployment` step (please see below).

## Deployment
Terraform based deployment of the U-ADS infrastructure into MCP-AWS consists of three steps:
1. Initial deployment that creates AWS resources required by the application
2. Dockstore application deployment
3. AWS lambda deployment

### 1. Initial Deployment 
The initial deployment consists of many AWS resources required prior to deploying the actual application (IAM Roles and Privileges, DB, LoadBalancer, etc.). The steps are as follows:

1. Change to the `application_package/dockstore/initial_deploy` directory of your working copy of the repository
2. Download and copy the private key for the GitHub App that communicates with Dockstore into the `s3` subdirectory. It should be tarred and gzipped and have the name `dockstore-github-private-key.pem.tar.gz`
3. Set temporary AWS access keys using `MCP Tenant Systems Administrator` role in Kion
4. Run `terraform init`
5. Run `terraform apply`

### 2. Application Deployment
There is a GitHub app that talks to the GitHub Lambda, which will be deployed later in the instruction set. It needs proper URLs for the WebHook, Callback, and Homepage settings. The WebHook URL should not change frequently, as it is dependent on the API Gateway in the AWS environment and pre-defined resources within it, and the API Gateway is pretty static. 

The Callback and Dockstore Homepage settings should follow the convention `<LOAD_BALANCER_DNS_NAME>:9998` where `<LOAD_BALANCER_DNS_NAME>` is the output LB DNS name (`LoadBalancerDNSName`) from the Load Balancer Stack (accessible through `AWS Console: CloudFormation -> Stacks -> awsLBDockstoreStack -> Outputs`) created in the initial deployment. We use port `9998` due to security constraints that limit the use of low numbered ports - this is in the CloudFormation config.

Each deployment environment requires a separate app, and currently the apps are:
* for the prod: TODO: add docs on how to create it
* for the dev: https://github.com/apps/jpl-uads-dockstore-dev-1 
* for the test: https://github.com/apps/jpl-uads-dockstore

#### Deployment
The Dockstore application is installed within an EC2 instance and this step handles standing it up. The steps are as follows:

1. Change to the `application_package/dockstore/app_deploy/app` directory (relative to `application_package/dockstore/initial_deploy` it is `../app_deploy/app`)
2. Set temporary AWS access keys using `MCP Tenant Systems Administrator` role in Kion
3. Run `terraform init`
4. Run `terraform apply`

### 3. Lambda Deployment

#### Admin User Account
The lambda deployment requires an administrator account's Dockstore token for authentication. To create this:

1. Register a user (`yourname`) for the Dockstore deployment by accessing `<LOAD_BALANCER_DNS_NAME>:9998` URL (please see step #2 above)  - currently only able to do this with public GitHub credentials
2. Update the database to make the user an admin:
	* Locate DB instance URL (accessible from `AWS Console: CloudFormation -> Stacks -> awsDbDockstoreStack -> Outputs -> DBAddress`) - the value is referenced as `DB_URL` below
	* Connect to the Dockstore APP EC2 using AWS Console
	* Set admin permissions for the `username` (admin user name in Dockstore):
	
	psql -h "`DB_URL`” -U dockstore -p 5432 --password --dbname=postgres
	
	UPDATE public.enduser SET isadmin=TRUE WHERE username='`yourname`';
	
	UPDATE public.enduser SET curator=TRUE WHERE username='`yourname`';
	
3. Access the token from the account info on the Dockstore webpage or the database and set the environment variable `TF_VAR_dockstore_token` with that value:

	export TF_VAR_dockstore_token="`tokenvalue`"

#### Deployment
To deploy the GitHub Lambda please follow the steps:

1. Change to the `application_package/dockstore/app_deploy/lambda` directory (relative to `application_package/dockstore/app_deploy/app` it is `../lambda`)
2. Set temporary AWS access keys using `MCP Tenant Systems Administrator` role in Kion
3. Run `terraform init`
4. Run `terraform apply`

The EC2 instance that the application is run on can be connected to via SSM either in the AWS Web UI or using the `aws ssm` CLI command. You can connect in order to debug any issues with the application, and it is the only location from which you can connect to the RDS/Database instance.


