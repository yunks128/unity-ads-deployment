#!/bin/sh

# Get apt package list
sudo apt update

# NFS client for access to EFS
sudo apt install nfs-client

# Allow access to NFS
sudo ufw allow out 2049
