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

For each deployment instance (ie. development, test, production) there are environment variables that need customization before proceeding with deployment. The `vars_jupyter.example.sh` contains a template of variables available to define Terraform variables. Copy this file to a new file named `vars_jupyter.sh` then modify as indicated below.

The following variables are required to be defined before proceeding with deployment:

```
export TF_VAR_tenant_identifier="example-dev"
export TF_VAR_efs_identifier="uads-venue-dev-efs-fs"
```

The `tenant_identifier` variable defines a unique string to be used in the deployed resources. It should be unique and descriptive of the current deployment. The `efs_identifier` variable is used to create the EFS shared storage resource that either exists already or will be created during deployment.

Each of the following Development Environment components need to be initialized individually by changing into their respective directory and running Terraform there. The Development Environment base directory under the repository is located in the `dev_env/` subdirectory.

The steps below assume that the above environment variables have already been defined. Additionally, you will need to ensure that AWS has access to the venue account.

### EFS Shared Storage

Shared storage must be installed prior to initializing Jupterhub. The Terraform scripts in this directory create an EFS server for Jupyterhub intended to host files common to all users. These scripts are separated out from the Jupyterhub installation scripts to enable removing and rebuilding the Jupyterhub instance without deleting the EFS stored files.

1. Change to the `dev_env/shared_storage` directory
2. Run `terraform init`
3. Run `terraform apply`

### Cognito Initial Setup

The connection of the Juptyterhub instance to the Unity Cognito Authentication requires running commands from the `cognito` directory twice. This deployment should be run connecting to the appropriate shared services AWS account instead of the venue's AWS account.

The initial set up will generate a Cognito application client along with the client id and secret necessary for feeding into the Jupyterhub deployment.

1. Set AWS credentials in a separate window from the venue deployment to the appropriate shared services credentials
2. Change to the `dev_env/cognito` directory
3. Run `terraform init`
4. Run `terraform apply`

Once Terraform has finished successfully run the following to display the Cognito id and secret into environment variables to be used by Juptyerhub.

```
$ ./cognito_config_envs.sh
```

Copy the output of this script into your `vars_jupyter.sh` script to replace the uninitialized values from the template. Make sure you reevaluate the `vars_jupyter.sh` script from your venue deployment window.

### Jupyterhub

Jupyterhub must be installed after the EFS shared storage Terraform scripts and Cognito initial step have been run. 

1. Change to the `dev_env/jupyterhub` directory
2. Reevaluate the `vars_jupyter.sh` script modified in the last step to include the Cognito variable values.
3. Run `terraform init`
4. Run `terraform apply`

If this is the first time this particular cluster has been deployed and you have multiple clusters listed in your Kubernetes config file, it is recommended to keep the `KUBE_CONFIG_PATH` environment variable unset. This avoids an issue with the EKS system within Terraform getting confused by trying to access a non-existent cluster .

The following useful variables are output from the Terraform execution:

* jupyter\_base\_uri - The URL used to log into the Jupyterhub cluster
* eks_cluster_name - The name of the generated EKS cluster
* kube_namespace - The namespace used with `kubectl` for investigating the EKS cluster

After successfully running the Terraform script for this directory for the first time, for subsequent runs of the Terraform scripts, you must define the `KUBE_CONFIG_PATH` environment variable:

```
export KUBE_CONFIG_PATH=$HOME/.kube/config
```

Next, run the `update_kube_config.sh` script to use the generated EKS cluster name from Terraform to create a new entry in the Kubernetes config file to allow the use of the kubectl command for querying the cluster.

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

Change back to the command prompt using the shared services AWS credentials. In the `cognito` directory run the following sequence to publish the Jupyterhub callback URL to Cognito:

```
$ eval $(./jupyter_uri_env.sh)
$ env | grep TF_VAR_jupyter_base_url
$ terraform apply 
```

Now that the `TF_VAR_jupyter_base_url` variable has been defined the Terraform process will update the Cogntio client to allow connection from the Jupyterhub instance.

### Test Jupyterhub

Now to test Jupyterhub installation by navigating to the URL from the `jupyter_base_uri` Terraform output from the `jupyterhub` directory.

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

