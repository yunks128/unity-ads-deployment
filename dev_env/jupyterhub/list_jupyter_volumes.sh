#!/bin/bash

aws ec2 describe-volumes \
  --filters 'Name=tag:kubernetes.io/created-for/pvc/namespace,Values=jhub-*' \
  --query "Volumes[*].{ID:VolumeId,Attachments:Attachments[].State,Tags:Tags[?Key == 'kubernetes.io/created-for/pvc/name']}" \
  --output json | jq -r '.[] | "\(.ID) \(.Tags[0].Value) \(.Attachments[0])"'
