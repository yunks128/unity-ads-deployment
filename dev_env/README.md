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
export TF_VAR_unity_instance="Unity-Test"
export TF_VAR_tenant_identifier="test"
export TF_VAR_cognito_base_url="https://unitysds-test.auth.us-west-2.amazoncognito.com"
export TF_VAR_s3_identifier="test"
```

The `unity_instance` variable should match the string used in the Unity instance's VPC name as this variable is used to look up the VPC. The `cognito_base_url` can be found from the "App Integration" tab of the user pool's information screen through the AWS web interface. The `s3_identifier` variable must match the instance string inserted into the names of the instance's Cumulus S3 buckets.

Each of the following Development Environment components need to be intialized individually by changing into their respective directory and running Terraform there. The Development Enviroment base directory under the repository is `dev_env/`.

### Shared Storage

Shared storage must be installed prior to initalizing Jupterlab. The Terraform scripts in this directory create an EFS server for Jupyterlab intended to host files common to all users. These scripts are seperated out from the Jupyterlab installation scripts to enable removing and rebuilding the Jupyterlab instance without deleting the EFS stored files.

1. Change to the `dev_env/shared_storage` directory
2. Run `terraform init`
3. Run `terraform apply`

### Jupyterlab

Jupyterlab must be installed after the EFS shared storage Terraform scripts have run. These scripts require the creation of a private key that will be used set up self signed certificates in the Application Load Balancer.

1. Change to the `dev_env/jupyterlab` directory
2. Generate the `private_key.pem` file: `$ openssl genrsa -out private_key.pem 2048`
3. Run `terraform init`
4. Run `terraform apply`

These scripts set up an EKS cluster. To access the cluster you must first initialize your `~/.kube/config` configuration file by running the following command:

```
$ aws eks update-kubeconfig --region us-west-2 --name uads-${TF_VAR_tenant_identifier}-jupyter-cluster
```

Now you can query the status of the cluster nodes as follows:

```
$ kubectl --namespace=jhub-${TF_VAR_tenant_identifier} get pods
```

The status for all pods should be ``Running``. If not query to log from the 

```
$ kubectl --namespace=jhub-${TF_VAR_tenant_identifier} logs ${pod_id}
```

Where `${pod_id}` comes from the output of the `get pods` command.

### EC2 Support Instance

The Support EC2 instance is used to manage the EFS shared storage. It must be installed after the EFS shared storage Terraform scripts have run. These scripts require the creation of a private key that will be used for logging into the instance.

1. Change to the `dev_env/support_instance` directory
2. Generate the `private_key.pem` file: `$ openssl genrsa -out private_key.pem 2048`
3. Run `terraform init`
4. Run `terraform apply`
5. Set up AWS [SSH connections through Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html)

After the instance is up and running log into the instance through session manager using the private key as follows:
```
$ ssh-add private_key.pem
$ ssh ubuntu@${instance_id}
```

Where `${instance_id}` substitutes for the EC2 instance ID from the output of the Terraform scripts.

EFS shared storage will be mounted as `/efs`. The mount can be written to by using `sudo`.

