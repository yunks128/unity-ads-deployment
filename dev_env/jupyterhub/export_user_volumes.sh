#!/usr/bin/env bash

script_dir=$(dirname $0)
cd $script_dir

output_dir=$1

if [ -z "$output_dir" ]; then
    echo "No output directory given"
    exit 1
fi

if [ ! -e "$output_dir" ]; then
    echo "$output_dir does not exist"
    exit 1
fi

namespace=$(terraform output -raw kube_namespace)
echo "Using Kubernetes namespace: $namespace"

# Find the volume claims for users in the form of 'claim-*'
user_claims=$(kubectl -n "$namespace" get pvc --no-headers | grep '^claim-' | awk '{print $1}')

for claim_name in $user_claims; do
    pvc_filename="$output_dir/pvc-${claim_name}.json"
    pv_filename="$output_dir/pv-${claim_name}.json"

    # Save PVC and PV onfig
    echo "Saving $claim_name to $pvc_filename"
    kubectl -n "$namespace" get pvc "$claim_name" -o json | \
        jq '' > $pvc_filename

    volume_name=$(jq -r .spec.volumeName $pvc_filename)

    echo "Setting $volume_name to Retain"
    # Make PV persist even if the claim is removed
    kubectl -n "$namespace" patch pv "$volume_name" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'

    # Must remove spec.claimRef or it will delete the existing volume on import
    echo "Saving $volume_name to $pvc_filename"
    kubectl -n "$namespace" get pv "$volume_name" -o json | \
        jq 'del(.spec.claimRef)' > $pv_filename
done
