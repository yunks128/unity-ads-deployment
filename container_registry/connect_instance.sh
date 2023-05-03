#!/bin/bash

# Extract private key and add to ssh agent
priv_key_file=$(mktemp)
terraform output -raw private_key_pem > $priv_key_file
ssh-add $priv_key_file
rm $priv_key_file

# Connect and port forward the internal server to localhost
ssh ec2-user@$(terraform output -raw instance_id) -L 8000:localhost:32543 $*
