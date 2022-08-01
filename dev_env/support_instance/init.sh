#!/bin/sh

# Become the root user
sudo su

# Get apt package list
apt update -y

# NFS client for access to EFS
apt install -y nfs-client

# Allow access to NFS
ufw allow out 2049

# Mount EFS volume
mkdir -p /efs
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_ip_address}:/ /efs
