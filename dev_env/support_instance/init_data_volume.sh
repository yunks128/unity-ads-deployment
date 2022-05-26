#!/bin/sh
sudo mkfs -t ext4 /dev/xvdg
sudo mkdir -p /mnt/app_dev_data
sudo mount /dev/xvdg /mnt/app_dev_data
sudo aws s3 sync s3://unity-ads-application-dev/ /mnt/app_dev_data
