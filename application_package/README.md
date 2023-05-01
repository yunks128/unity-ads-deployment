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

## S3 bucket to store Load Balancer Logs
MCP does not allow us to create S3 bucket policies, so we need to create S3 bucket manually before deploying the application.
Please use the following tags when creating the S3 bucket from `AWS Console: S3` (with an example of "development" environment):

* ServiceArea:	ads
* Proj: unity
* Venue: Dev
* Component: Dockstore
* Env: Dev
* Stack: Dockstore
  
Once the bucket is created, please submit an MCP request to attach the bucket policy to allow for Load Balancer logs to be stored in the bucket (per [AWS docs](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html)). Once S3 bucket's policy has been attached, proceed to the application deployment.

## Setting up Development Environment

For each deployment instance (ie. development, test, production) define the following environment variables to customize the install to the environment. For example, for the `dev` (development) deployment you would defined the following variables:

```
export TF_VAR_resource_prefix=dev
export TF_VAR_api_id=value1
export TF_VAR_api_parent_id=value2
export TF_VAR_availability_zone=us-west-2b
export TF_VAR_lb_logs_bucket_name="uads-dev-dockstore-elb-logs"

# Optional variable to set AWS ARN for the database manual snapshot to preserve
# database between the application deployments.
# If default empty string is used for the ARN, then newly created database will be empty.
export TF_VAR_db_snapshot=""

# Do not worry about populating these tokens correctly for infrastructure/initial deploy (step #1 below),
# they will need to be set for the deployment of the Dockstore API in step #2:
export TF_VAR_dockstore_token=""
export TF_VAR_eni_private_ip=""
```

Where:

`resource_prefix` - one of `dev`, `test`, or `prod` and represents the environment is being deployed.

`api_id` - the ID assigned to the `Unity API Gateway`.

`api_parent_id` - the ID assigned to the desired parent resource for the new dockstore method in `Unity API Gateway` - currently we are using `/ads`. 

Note: Both ID values are accessible through `AWS Console: API Gateway -> Unity API Gateway` where upper toolbar lists the ID values: `APIs > Unity API Gateway (value1) > Resources > /ads (value2)`

`availability_zone` - the availability zone requested for the DB and other resources and should match available subnets availability zones.

`lb_logs_bucket_name` - the name of manually created S3 bucket to store application's Load Balancer logs. 

`db_snapshot` - optional AWS ARN of the manual database snapshot. Please be aware that automatically generated backup snapshots will be deleted when original database is destroyed. To preserve database between deployments user needs to create manual database snapshot through `AWS Console:  RDB -> Select awsdbdockstorestack-dbinstance* database -> "Maintenance & backups" tab -> "Take snapshot" under "Actions"`.

`dockstore_token` - the Dockstore administrator account token that will be used for the GitHub Lambda authentication. The token is accessible from the Dockstore user account once the Dockstore application is deployed and administrator user is registered with the application. Please note that `dockstore_token` cannot be set until after the Dockstore application has been deployed in the `#2. Application Deployment` step (please see below).

`eni_private_ip` - Pre-defined IP address to associate with ENI (Elastic Network Interface). This private IP address within private subnet (corresponding to the AZ for the deployment) is associated with EIP of the EC2 instance where the Dockstore API is running. This address needs to be manually picked from any available IP addresses within the private subnet that corresponds to the AZ for the deployment.

## Deployment
Terraform based deployment of the U-ADS infrastructure into MCP-AWS consists of three steps:
1. Initial deployment that creates AWS resources required by the application
2. Dockstore application deployment
3. AWS lambda deployment

### 1. Initial Deployment 
The initial deployment consists of many AWS resources required prior to deploying the actual application (IAM Roles and Privileges, DB, LoadBalancer, etc.). The steps are as follows:

1. Change to the `application_package/dockstore/initial_deploy` directory of your working copy of the repository
2. Download and copy the private key for the GitHub App for the environment being deployed that communicates with Dockstore into the `s3` subdirectory. It should be tarred and gzipped and have the name `dockstore-github-private-key.pem.tar.gz`
3. Set temporary AWS access keys using `MCP Tenant Systems Administrator` role in Kion
4. Run `terraform init`
5. Run `terraform apply`

### 2. Application Deployment
The Dockstore application is installed within an EC2 instance and this step handles standing it up. 

A private IP address needs to be selected for the ENI association to the EIP of the EC2 instance we are about to create. Please follow these steps in to identify available private IP addresses within private subnet that corresponds to the Availability Zone (AZ) for the deployment (as specified by `TF_VAR_availability_zone` environment variable):
1. Access Subnets through `AWS Console: VPC -> VPCs`, select Unity-Dev-VPC, select `Unity-Dev-Priv-SubnetXX` tab and get an ID of the subnet for the AZ of the deployment `subnet-xxxxx`
2. Set temporary AWS access keys using `MCP Tenant Systems Administrator` role in Kion
3. Run command, which will display all private IPs in use:
   ```aws ec2 describe-network-interfaces --filters Name=subnet-id,Values=subnet-xxxxx | grep 'PrivateIpAddress":' | grep -v ','| sort```
4. Select any not used private IP address for the subnet
5. Set `TF_VAR_eni_private_ip` to the selected IP address

#### Deployment
The steps are as follows:

1. Change to the `application_package/dockstore/app_deploy/app` directory (relative to `application_package/dockstore/initial_deploy` it is `../app_deploy/app`)
2. Set temporary AWS access keys using `MCP Tenant Systems Administrator` role in Kion
3. Run `terraform init`
4. Run `terraform apply`

The Dockstore application homepage URL follows the convention `<LOAD_BALANCER_DNS_NAME>:9998` where `<LOAD_BALANCER_DNS_NAME>` is the output LB DNS name (`LoadBalancerDNSName`) from the Load Balancer Stack (accessible through `AWS Console: CloudFormation -> Stacks -> awsLBDockstoreStack -> Outputs`) created in the initial deployment. We use port `9998` due to security constraints that limit the use of low numbered ports - this is in the CloudFormation config.

**TODO:** There is a whole bunch of manually set AWS parameters as required by the Dockstore deployment, which could be replaced by Terraform variables (for example, search for `/DeploymentConfig/dev/` in `AWS Console: AWS Systems Manager -> Parameter Store` for the development environment).

#### GitHub App 
GitHub App is used to connect authentication and repositories to the JPL Unity Dockstore instance in the MCP environment being deployed.

GitHub App talks to the AWS Lambda, which will be deployed later in step `3. Lambda Deployment`. The GitHub App needs proper URLs for the WebHook, Callback, and Homepage settings. The WebHook URL should not change frequently, as it is dependent on the API Gateway in the AWS environment and pre-defined resources within it, and the API Gateway is pretty static.

##### Setting up the GitHub App
If the GitHub App already exists, you only need to update `Homepage URL` and `Callback URL` in its configuration, and continue to step `3. Lambda Deployment`.

If it is very first time setting up the environment, please register new GitHub App using the following configuration:
* Homepage URL: `<LOAD_BALANCER_DNS_NAME>:9998`
* Callback URL: `<LOAD_BALANCER_DNS_NAME>:9998`
* Expire user authorization tokens: enable
* Request User authorization (OAuth) during installation: enable
* Webhook URL:
  - The webhook, as generated by step `1. Initial Deployment`, is accessible through `AWS Console: API Gateway -> Unity API Gateway` where upper toolbar lists the resource path `APIs > Unity API Gateway (value1) > Resources > /ads/dockstore/webhooks/github/enqueue (value3)` within URL. 
  - URL is accessible through `AWS Console: API Gateway -> Unity API Gateway -> Stages` - select the stage and URL appears under `Invoke URL` in the top level toolbar. For example, the Webhook URL follows the convention `https://**insert_value1_from_above**.execute-api.us-west-2.amazonaws.com/dev/ads/dockstore/webhooks/github/enqueue` for the development deployment.
* Webhook secret:
  - The webhook secret value is accessible through `AWS Console: AWS Systems Manager -> Parameter Store -> /DeploymentConfig/dev/SecretToken` which is set manually for the environment through AWS Console. 
* SSL verification: disable for now
* Repository permissions:
  - Actions, Codespaces, Codespaces lifecycle admin, Codespaces metadata, Commit statuses, Contents, Metadata: set to `Read-only`
* Subscribe to events:
  - Create, Fork, Label, Push, Repository, Delete, Public, Release, Star: enable
* Where can this GitHub App be installed? - Any account

Each deployment environment requires a separate GitHub App, and currently the apps are:
* for the prod: TBD
* for the dev: https://github.com/apps/unity-ads-dockstore-dev
* for the test: https://github.com/apps/jpl-uads-dockstore

Set AWS Parameters through `AWS Console: AWS Systems Manager -> Parameter Store` which store corresponding value of the GitHub App:
* /DeploymentConfig/dev/GitHubAppId
* /DeploymentConfig/dev/GitHubAppName
* /DeploymentConfig/dev/GitHubClientId
* /DeploymentConfig/dev/GitHubClientSecret: generate new client secret within GitHub App and use the value for the parameter

Once GitHub App is created, install it in your GitHub account, and add GitHub workflow repositories to grand the App access to.

### 3. Lambda Deployment

#### Admin User Account
The lambda deployment requires an administrator account's Dockstore token for authentication. To create this:

1. Register a user (`yourname`) for the Dockstore deployment by accessing `<LOAD_BALANCER_DNS_NAME>:9998` URL (please see step #2 above)  - currently only able to do this with public GitHub credentials
2. Update the database to make the user an admin:
	* Locate DB instance URL (accessible from `AWS Console: CloudFormation -> Stacks -> awsDbDockstoreStack -> Outputs -> DBAddress`) - the value is referenced as `DB_URL` below
	* Connect to the Dockstore APP EC2 using AWS Console
	* Set admin permissions for the `username` (admin user name in Dockstore - ask https://www.github.com/mcduffie or https://www.github.com/mliukis for the password):
	
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

## Deployment Logs
Load Balancer logs are stored in AWS S3 bucket (for example, `s3://uads-dev-dockstore-elb-logs` for the development environment).

To examine deployment logs for the application, please find EC2 instance the application is running on. The EC2 instance name is in the App Stack's Resources or can be found through the 'dockstore' search filter in the `AWS Console: EC2` (which is `awsAppDockstoreStack-instance`).  Connect to the instance through AWS's Session Manager.

Log details for the commands invoked to initialize the server during the CloudFormation run:

`sudo tail -n 100 /var/log/cloud-init-output.log`

To look at the various pieces of the application on the server:

```
sudo su ubuntu
cd ~/compose_setup/
export LOG_GROUP_NAME=awsagent-update.log
```

* Logs for the docker container that contains the actual web application (might have some errors that are logged during initialization, mostly related to log4j, but they are not fatal):

`docker logs --tail 100 compose_setup_webservice_1`

* Logs for the container that hosts the actual web server which handles web traffic

`docker logs --tail 100 compose_setup_nginx_dockstore_1`

* Logs for the container that contains software to check on the DB migration/setup. It will run once and then exit:

`docker logs --tail 100 compose_setup_migration_1`

**Notes**
1. The initial standup of the web app, etc. takes 5-10 minutes after CloudFormation reports success, so if the URL isn't immediately working, that is OK.
2. There will be WARNING messages in the `compose_setup_webservice_1` log, but as long as `org.eclipse.jetty.server.Server: Started` message is displayed after these warnings, the Dockstore instance is fully up and ready to accept requests.

## Shutdown Deployment

To shutdown U-ADS deployment, run `terraform destroy` in reverse order[^1]:

1. Lambda:
Set temporary AWS access keys using MCP Tenant Systems Administrator role in Kion

```
cd application_package/dockstore/app_deploy/lambda
terraform destroy
```

2. Application:
```
cd application_package/dockstore/app_deploy/app
terraform destroy
```

3. Initial deployment:
```
cd application_package/dockstore/initial_deploy
terraform destroy
```

[^1]: Remember to set temporary AWS access keys using MCP Tenant Systems Administrator role in Kion prior to each `terraform` command.
