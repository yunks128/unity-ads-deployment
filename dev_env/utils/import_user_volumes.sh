#!/usr/bin/env bash

script_dir=$(dirname $0)
cd $script_dir

input_dir=$1

if [ -z "$input_dir" ]; then
    echo "No input directory given"
    exit 1
fi

if [ ! -e "$input_dir" ]; then
    echo "$input_dir does not exist"
    exit 1
fi

for pv_file in $input_dir/pv-*; do
    echo "Creating PV from: $pv_file"
    kubectl create -f $pv_file
done

for pvc_file in $input_dir/pvc-*; do
    echo "Creating PVC from: $pvc_file"
    kubectl create -f $pvc_file
done
