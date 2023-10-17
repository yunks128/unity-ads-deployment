#!/usr/bin/env bash

# Uses AWS to update Kubernetes config file to point to the EKS cluster 

script_dir=$(dirname $0)
cd $script_dir

if [ -z "$(which terraform 2>/dev/null)" ]; then
    echo "ERROR: terraform CLI is not installed"
    exit 1
fi

if [ -z "$(which aws 2>/dev/null)" ]; then
    echo "ERROR: aws CLI is not installed"
    exit 1
fi

cd $script_dir

aws eks update-kubeconfig --region us-west-2 --name $(terraform output -raw eks_cluster_name)
