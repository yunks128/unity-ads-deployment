#!/bin/bash

# Configuration
QUAY_DIR=/usr/local/quay
POSTGRESQL_USER=quayuser
POSTGRESQL_PASSWORD=${postgresql_user_password}
POSTGRESQL_DATABASE=quay
POSTGRESQL_ADMIN_PASSWORD=${postgresql_admin_password}
REDIS_PASSWORD=${redis_password}

# Number of seconds to try updating postgresql server to enable the pg_trgm extension
DB_UPDATE_RETRIES=20

POSTGRESQL_DOCKER_LABEL=docker.io/centos/postgresql-10-centos7@sha256:de1560cb35e5ec643e7b3a772ebaac8e3a7a2a8e8271d9e91ff023539b4dfb33
REDIS_DOCKER_LABEL=docker.io/centos/redis-32-centos7@sha256:06dbb609484330ec6be6090109f1fa16e936afcf975d1cbc5fff3e6c7cae7542
QUAY_DOCKER_LABEL=quay.io/projectquay/quay:v3.8.0

server_ip=10.88.0.1

# Administration scripts
postgresql_unit_file=/etc/systemd/system/postgresql-quay.service
postgresql_service_name=$(basename $postgresql_unit_file | sed 's/.service$//')

redis_unit_file=/etc/systemd/system/redis-quay.service
redis_service_name=$(basename $redis_unit_file | sed 's/.service$//')

quay_unit_file=/etc/systemd/system/quay-server.service
quay_service_name=$(basename $quay_unit_file | sed 's/.service$//')

################################################################################
# System setup

# Install podman
yum update -y

# Install:
# * Ability to run podman containers
# * Postgresql commandline interface
# * screen for debugging interactively
yum module install -y container-tools postgresql
yum install -y screen

# Turn off SELinux for now or else get memory permission errors
setenforce 0
sed -i '/SELINUXTYPE/s/targeted/permissive/' /etc/selinux/config

################################################################################
## Postgres

# Create a directory for the database data and set the permissions appropriately
mkdir -p $QUAY_DIR/postgres-quay
setfacl -m u:26:-wx $QUAY_DIR/postgres-quay

# Create a systemd unit file for Postgresql
(
cat <<EOF
[Unit]
Description=PostgreSQL Podman Container for Quay
After=network.target

[Service]
Type=simple
TimeoutStartSec=5m
ExecStartPre=-/usr/bin/podman rm "postgresql-quay"

ExecStart=podman run --rm --name postgresql-quay -e POSTGRESQL_USER=$POSTGRESQL_USER -e POSTGRESQL_PASSWORD=$POSTGRESQL_PASSWORD -e POSTGRESQL_DATABASE=$POSTGRESQL_DATABASE -e POSTGRESQL_ADMIN_PASSWORD=$POSTGRESQL_ADMIN_PASSWORD -p 5432:5432 -v $QUAY_DIR/postgres-quay:/var/lib/pgsql/data:Z $POSTGRESQL_DOCKER_LABEL

ExecReload=-/usr/bin/podman stop "postgresql-quay"
ExecReload=-/usr/bin/podman rm "postgresql-quay"
ExecStop=-/usr/bin/podman stop "postgresql-quay"
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
) > $postgresql_unit_file

# Start the Postgres container
systemctl daemon-reload
systemctl enable $postgresql_service_name
systemctl start $postgresql_service_name
systemctl status --no-pager $postgresql_service_name

# Register pg_trgm extension into database needed by Quay
# Wait for postgresql to come up
until echo "CREATE EXTENSION pg_trgm;" | PGPASSWORD=$POSTGRESQL_ADMIN_PASSWORD psql -h localhost -p 5432 $POSTGRESQL_DATABASE postgres >/dev/null 2>&1 || [ $DB_UPDATE_RETRIES -eq 0 ]; do
  echo "Waiting for postgres server, $((DB_UPDATE_RETRIES--)) remaining attempts..."
  sleep 1
done

################################################################################
# Redis

# Create a systemd unit file for redis
(
cat <<EOF
[Unit]
Description=Redis Podman Container for Quay
After=network.target

[Service]
Type=simple
TimeoutStartSec=5m
ExecStartPre=-/usr/bin/podman rm "redis-quay"

ExecStart=podman run --rm --name redis-quay -p 6379:6379 -e REDIS_PASSWORD=$REDIS_PASSWORD $REDIS_DOCKER_LABEL

ExecReload=-/usr/bin/podman stop "redis-quay"
ExecReload=-/usr/bin/podman rm "redis-quay"
ExecStop=-/usr/bin/podman stop "redis-quay"
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
) > $redis_unit_file

# Start the Redis container
systemctl daemon-reload
systemctl enable $redis_service_name
systemctl start $redis_service_name
systemctl status --no-pager $redis_service_name

################################################################################
## Quay

quay_config_filename=$QUAY_DIR/config/config.yaml

# Prepare config folder and file
mkdir $QUAY_DIR/config

(
cat <<EOF
AUTHENTICATION_TYPE: Database
FEATURE_DIRECT_LOGIN: False
BUILDLOGS_REDIS:
    host: $server_ip 
    password: $REDIS_PASSWORD
    port: 6379
DATABASE_SECRET_KEY: 190a2d63-1416-4047-9736-f0efc00fec7a
DB_CONNECTION_ARGS: {}
DB_URI: postgresql://$POSTGRESQL_USER:$POSTGRESQL_PASSWORD@$server_ip:5432/$POSTGRESQL_DATABASE
DISTRIBUTED_STORAGE_CONFIG:
    default:
        - LocalStorage
        - storage_path: /datastorage/registry
SERVER_HOSTNAME: localhost:80
SETUP_COMPLETE: true
USER_EVENTS_REDIS:
    host: $server_ip 
    password: $REDIS_PASSWORD
    port: 6379
FEATURE_ANONYMOUS_ACCESS: False
FEATURE_USER_CREATION: False
FEATURE_MAILING: False
UNITY_LOGIN_CONFIG:
    CLIENT_ID: ${cognito_quay_client_id}
    CLIENT_SECRET: ${cognito_quay_client_secret}
    OIDC_SERVER: ${cognito_oidc_base_url}/${cognito_user_pool_id}/
    SERVICE_NAME: Unity SPS
EOF
) > $quay_config_filename

# Prepare local storage for image data
mkdir $QUAY_DIR/storage
setfacl -m u:1001:-wx $QUAY_DIR/storage

# Create a systemd unit file for quay
(
cat <<EOF
[Unit]
Description=Quay Podman Container 
Requires=$postgresql_service_name $redis_service_name
After=$postgresql_service_name $redis_service_name

[Service]
Type=simple
TimeoutStartSec=5m
ExecStartPre=-/usr/bin/podman rm "quay-server"

ExecStart=podman run --rm -p 80:8080 -p 443:8443 --name=quay-server -v $QUAY_DIR/config:/conf/stack:Z -v $QUAY_DIR/storage:/datastorage:Z $QUAY_DOCKER_LABEL

ExecReload=-/usr/bin/podman stop "quay-server"
ExecReload=-/usr/bin/podman rm "quay-server"
ExecStop=-/usr/bin/podman stop "quay-server"
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
) > $quay_unit_file

# Start the Redis container
systemctl daemon-reload
systemctl enable $quay_service_name
systemctl start $quay_service_name
systemctl status --no-pager $quay_service_name
