#!/usr/bin/env python3

import boto3
import logging
from time import sleep

PVC_TAG_NAME = 'kubernetes.io/created-for/pvc/name'
PVC_FILTER_VALUE = 'claim-*'

READY_STATES = ['completed']

SS_READY_WAIT_SECONDS = 2
SS_READY_TIMEOUT_COUNT = 5 * 60 // SS_READY_WAIT_SECONDS

logger = logging.getLogger()

def volume_claim_name(volume_info):
    claim_tags = list(filter(lambda t: 'Key' in t and t['Key'] == PVC_TAG_NAME, volume_info['Tags']))
    if len(claim_tags) == 0:
        raise Exception(f'Coult not find {PVC_TAG_NAME} tag in volume: {volume_info}')

    return claim_tags[0]['Value']

def jupyter_volume_claims(ec2_client):
    # Find Jupyter claims identified by their Kubernetes PVC tag named claim-*
    response = ec2_client.describe_volumes(Filters=[
        {
            'Name': f'tag:{PVC_TAG_NAME}',  # pvc/name
            'Values': [ PVC_FILTER_VALUE ], # claim-*
        },
    ])

    claim_volumes = response['Volumes']

    num_volumes = len(claim_volumes)
    logger.info(f'Found {num_volumes} Jupyterhub user volume claims:')

    for vol in claim_volumes:
        claim_name = volume_claim_name(vol)
        logger.info(f'* {claim_name}')

    return claim_volumes

def create_ebs_snapshot(ec2_client, volume_info):
    "Creates an initial copy of the EBS volume"

    claim_name = volume_claim_name(volume_info)
    user_name = claim_name.replace('claim-', '')
    description = f'Jupyterhub user data for {user_name}'

    tags = volume_info['Tags']

    # Add pulling tags pulling out information from the volume tags
    # to make further steps easier
    tags.append({'Key': 'user_name', 'Value': user_name})

    # Create initial snapshot encrypted the same way as the EBS volume
    response = ec2_client.create_snapshot(
        Description = description,
        VolumeId = volume_info['VolumeId'],
        TagSpecifications = [
            {
                'ResourceType': 'snapshot',
                'Tags': tags,
            },
        ],
    )

    return response

def num_snapshots_ready(ec2_client, snap_ids):

    if len(snap_ids) == 0:
        raise Exception("No snapshot IDs given")

    # Wait for snapshot to finish being built
    response = ec2_client.describe_snapshots(
        SnapshotIds = snap_ids,
    )

    ss_states = list(map(lambda ss_info: ss_info['State'], response['Snapshots']))
    ss_ready = list(filter(lambda state: state in READY_STATES, ss_states))

    return len(ss_ready)

def create_ebs_snapshot_copies(ec2_client, claim_volumes):

    logger.info(f'Creating initial EBS snapshot copies:')

    initial_snap_ids = []
    for volume_info in claim_volumes:
        claim_name = volume_claim_name(volume_info)

        response = create_ebs_snapshot(ec2_client, volume_info)
        snap_id = response['SnapshotId']
        initial_snap_ids.append(snap_id)

        logger.info(f'* {claim_name}: {snap_id}')

    return initial_snap_ids

def wait_for_snapshots(ec2_client, snap_ids):

    logger.info(f'Waiting for {len(snap_ids)} snapshots to finish creation')

    num_attempts = 0
    num_ready = 0
    while num_ready < len(snap_ids) and num_attempts < SS_READY_TIMEOUT_COUNT:
        num_ready = num_snapshots_ready(ec2_client, snap_ids)
        logger.info(f"{num_ready} / {len(snap_ids)} snapshots ready")
        sleep(SS_READY_WAIT_SECONDS)

    if num_ready < len(snap_ids):
        raise Exception("Not all snapshots finished creation")

def main():

    logging.basicConfig(level=logging.INFO)
    ec2_client = boto3.client('ec2')

    claim_volumes = jupyter_volume_claims(ec2_client)

    initial_snap_ids = create_ebs_snapshot_copies(ec2_client, claim_volumes)
    wait_for_snapshots(ec2_client, initial_snap_ids)

if __name__ == "__main__":
    main()
