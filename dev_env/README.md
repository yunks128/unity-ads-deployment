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
   * EFS Shared Storage
   * Jupyterhub
   * EC2 Support Instance (optional)

  
## Development Environment

For each deployment instance (ie. development, test, production) define the following environment variables to customize the install to the environment. For example for the test deployment you would defined the following variables:


```
export TF_VAR_unity_instance="Unity-Test"
export TF_VAR_tenant_identifier="test"
export TF_VAR_s3_identifier="test"
export TF_VAR_efs_identifier="uads-development-efs-fs"
```

The `unity_instance` variable should match the string used in the Unity instance's VPC name as this variable is used to look up the VPC. The `s3_identifier` variable must match the instance string inserted into the names of the instance's Cumulus S3 buckets. The `efs_identifider` variable is used to create the EFS shared storage resource.

Each of the following Development Environment components need to be intialized individually by changing into their respective directory and running Terraform there. The Development Enviroment base directory under the repository is `dev_env/`.

The steps below assume that the above environment variables have already been defined.

### EFS Shared Storage

Shared storage must be installed prior to initalizing Jupterlab. The Terraform scripts in this directory create an EFS server for Jupyterhub intended to host files common to all users. These scripts are seperated out from the Jupyterhub installation scripts to enable removing and rebuilding the Jupyterhubz instance without deleting the EFS stored files.

1. Change to the `dev_env/shared_storage` directory
2. Run `terraform init`
3. Run `terraform apply`

### Cognito Initial Setup

The connection of the Juptyterhub instance to the Unity Cognito Authentication requires running commands from the `cognito` directory twice.

The initial set up will generate a Cognito application client along with the client id and secret necessary for feeding into the Jupyterhub deployment.

1. Change to the `dev_env/cognito` directory
2. Run `terraform init`
3. Run `terraform apply`

Once Terraform has finished succesfully run the following to bring the Cognito id and secret into environment variables required in the next step.

```
$ eval $(./cognito_config_envs.sh)
```

Run the following to verify that the environment variables were succesfully set up:

```
$ env | grep TF_VAR_cogn
```

Note that the Cognito resource could exist in a seperate venue from the Jupyterhub instance.

### Jupyterhub

Jupyterhub must be installed after the EFS shared storage Terraform scripts and Cognito initial step have been run. 

1. Change to the `dev_env/jupyterhub` directory
2. Run `terraform init`
3. Run `terraform apply`

For the above steps it is recommended to keep the `KUBE_CONFIG_PATH` environment variable unset, or else the EKS system within Terraform might get confused by trying to access a non-existent cluster if this is the first time this particular cluster has been set up and you have multiple clusters listed in your Kubernetes config file.

Two useful variables are output from the Terraform execution:

* jupyter\_base\_uri - The URL used to log into the Jupyterhub cluster
* eks_cluster_name - The name of the generated EKS cluster
* kube_namespace - The namespace used with `kubectl` for investigating the EKS cluster

But after successfully running the Terraform script for this directory for the first time, for subsequent runs to update changes to the Terraform scripts you must define the `KUBE_CONFIG_PATH` environment variable:

```
export KUBE_CONFIG_PATH=$HOME/.kube/config
```

Run the `update_kube_config.sh` script to use the generated EKS cluster name from Terraform to create a new entry in the Kubernetes config file to allow use of the kubectl command for querying the cluster.

Now you can query the status of the cluster nodes as follows:

```
$ kubectl --namespace=$kube_namespace get pods
```

The status for all pods should be ``Running``. If not query to log from the 

```
$ kubectl --namespace=$kube_namespace logs $pod_id
```

Where `$pod_id` comes from the output of the `get pods` command.

### Cognito Final Setup

Change back to the `cognito` directory to run the following sequence to publish the Jupyterhub callback URL to Cognito:

```
$ eval $(./jupyter_uri_env.sh)
$ env | grep TF_VAR_jupyter_base_url
$ terraform apply 
```

Now that the `TF_VAR_jupyter_base_url` variable has been defined the Terraform process will update the Cogntio client to allow connection from the Jupyterhub instance.

### Test Jupyterhub

Now to test Jupyterhub installation by navigating to the URL from the `jupyter_base_uri` output from the `jupyterhub` directory.

### EC2 Support Instance

The Support EC2 instance can optionally be used to manage the EFS shared storage. It must be installed after the EFS shared storage Terraform scripts have run. These scripts require the creation of a private key that will be used for logging into the instance.

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

