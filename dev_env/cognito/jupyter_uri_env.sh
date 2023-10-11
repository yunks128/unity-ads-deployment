#!/usr/bin/env bash

# Uses AWS to extract information to feed to the Jupyter stage as variables for setting up the connection to cognito
# terraform apply must have already been run

script_dir=$(dirname $0)

if [ -z "$(which terraform 2>/dev/null)" ]; then
    echo "ERROR: terraform CLI is not installed"
    exit 1
fi

cd $(realpath $script_dir/..)/jupyterlab

jupyter_uri=$(terraform output -raw jupyter_base_uri)

echo "export TF_VAR_jupyter_base_uri=\"${jupyter_uri}\""
