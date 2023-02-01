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

* Application Catalog
	* Dockstore
		* Infrastructure
		* Application
		* GitHub Lambda
## Contents

* [Quick Start](#quick-start)
* [Changelog](#changelog)
* [FAQ](#frequently-asked-questions-faq)
* [Contributing Guide](#contributing)
* [License](#license)
* [Support](#support)

## Quick Start

This guide provides instructions on how to setup an environment for using these deployment scripts. It gives details about the variables that need to be defined for each deployment. Also included are useful pointers on checking deployment status.

### Requirements

* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html) 

### Setup Instructions

1. Install Terraform according to [their instructions](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. Install EKS related requirements listed above using the [Getting started with Amazon EKS
](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html) instructions.

When checking out this repository keep a separate copy for each deployment instance (ie. development, test, production). This will simplify management and keep their Terraform state files seperated.
  
## License

See our: [License](LICENSE.txt)

## Support

Key points of contact are: 

* [@mcduffie](https://github.com/mcduffie)


<!-- ☝️ Replace with the key individuals who should be contacted for questions ☝️ -->
