# Configuration
QUAY_DIR=/usr/local/quay
POSTGRESQL_USER=quayuser
POSTGRESQL_PASSWORD=quaypass
POSTGRESQL_DATABASE=quay
POSTGRESQL_ADMIN_PASSWORD=adminpass
REDIS_PASSWORD=strongpassword 

server_ip=10.88.0.1

# Administration scripts
postgres_script=$QUAY_DIR/bin/start_postgresql.sh
redis_script=$QUAY_DIR/bin/start_redis.sh
quay_script=$QUAY_DIR/bin/start_quay.sh
rerun_script=$QUAY_DIR/bin/restart_all.sh

# Function to initialize scripts created for each component
function init_script {
    script_filename=$1

    (
    cat <<EOF
#!/bin/bash
QUAY_DIR=$QUAY_DIR
POSTGRESQL_USER=$POSTGRESQL_USER
POSTGRESQL_PASSWORD=$POSTGRESQL_PASSWORD
POSTGRESQL_DATABASE=$POSTGRESQL_DATABASE
POSTGRESQL_ADMIN_PASSWORD=$POSTGRESQL_ADMIN_PASSWORD
REDIS_PASSWORD=$REDIS_PASSWORD

EOF
) > $script_filename

    chmod u+x $script_filename
}

# Install podman
yum update -y

# Install:
# * Ability to run podman containers
# * Postgresql commandline interface
yum module install -y container-tools postgresql

# Turn off SELinux for now or else get memory permission errors
setenforce 0

# Create quay bin directory for scripts we will create for launching the service
mkdir -p $QUAY_DIR/bin
setfacl -m u:26:-wx $QUAY_DIR/bin

####
## Postgres

# Create a directory for the database data and set the permissions appropriately
mkdir -p $QUAY_DIR/postgres-quay
setfacl -m u:26:-wx $QUAY_DIR/postgres-quay

# Create a reusable script for launching postgres
init_script $postgres_script

(
cat <<EOF
podman container stop -i postgresql-quay
podman container rm -i postgresql-quay

podman run -d --rm --name postgresql-quay \
  -e POSTGRESQL_USER=\$POSTGRESQL_USER \
  -e POSTGRESQL_PASSWORD=\$POSTGRESQL_PASSWORD \
  -e POSTGRESQL_DATABASE=\$POSTGRESQL_DATABASE \
  -e POSTGRESQL_ADMIN_PASSWORD=\$POSTGRESQL_ADMIN_PASSWORD \
  -p 5432:5432 \
  -v $QUAY_DIR/postgres-quay:/var/lib/pgsql/data:Z \
  docker.io/centos/postgresql-10-centos7@sha256:de1560cb35e5ec643e7b3a772ebaac8e3a7a2a8e8271d9e91ff023539b4dfb33
EOF
) >> $postgres_script

# Start the Postgres container
$postgres_script

# Wait for postgres to come up
sleep 2

# Register pg_trgm extension into database needed by Quay
echo "CREATE EXTENSION pg_trgm;" | PGPASSWORD=$POSTGRESQL_ADMIN_PASSWORD psql -h localhost -p 5432 $POSTGRESQL_DATABASE postgres

####
# Redis

# Create a reusable script for launching redis
init_script $redis_script

(
cat <<EOF
podman container stop -i redis-quay
podman container rm -i redis-quay

podman run -d --rm --name redis-quay \
  -p 6379:6379 \
  -e REDIS_PASSWORD=\$REDIS_PASSWORD \
  docker.io/centos/redis-32-centos7@sha256:06dbb609484330ec6be6090109f1fa16e936afcf975d1cbc5fff3e6c7cae7542
EOF
) >> $redis_script

# Start the Redis container
$redis_script

####
## Quay

quay_config_filename=$QUAY_DIR/config/config.yaml

# Prepare config folder and file
mkdir $QUAY_DIR/config

(
cat <<EOF
AUTHENTICATION_TYPE: Database
AVATAR_KIND: local
BUILDLOGS_REDIS:
    host: ${server_ip} 
    password: ${REDIS_PASSWORD}
    port: 6379
DATABASE_SECRET_KEY: 190a2d63-1416-4047-9736-f0efc00fec7a
DB_CONNECTION_ARGS: {}
DB_URI: postgresql://${POSTGRESQL_USER}:${POSTGRESQL_PASSWORD}@${server_ip}:5432/${POSTGRESQL_DATABASE}
DEFAULT_TAG_EXPIRATION: 2w
DISTRIBUTED_STORAGE_CONFIG:
    default:
        - LocalStorage
        - storage_path: /datastorage/registry
DISTRIBUTED_STORAGE_DEFAULT_LOCATIONS: []
DISTRIBUTED_STORAGE_PREFERENCE:
    - default
EXTERNAL_TLS_TERMINATION: true
FEATURE_ACI_CONVERSION: false
FEATURE_ACTION_LOG_ROTATION: false
FEATURE_ANONYMOUS_ACCESS: true
FEATURE_APP_REGISTRY: false
FEATURE_APP_SPECIFIC_TOKENS: true
FEATURE_BITBUCKET_BUILD: false
FEATURE_BLACKLISTED_EMAILS: false
FEATURE_BUILD_SUPPORT: false
FEATURE_CHANGE_TAG_EXPIRATION: true
FEATURE_DIRECT_LOGIN: true
FEATURE_EXTENDED_REPOSITORY_NAMES: true
FEATURE_FIPS: false
FEATURE_GITHUB_BUILD: false
FEATURE_GITHUB_LOGIN: false
FEATURE_GITLAB_BUILD: false
FEATURE_GOOGLE_LOGIN: false
FEATURE_INVITE_ONLY_USER_CREATION: false
FEATURE_MAILING: false
FEATURE_NONSUPERUSER_TEAM_SYNCING_SETUP: false
FEATURE_PARTIAL_USER_AUTOCOMPLETE: true
FEATURE_PROXY_STORAGE: false
FEATURE_REPO_MIRROR: false
FEATURE_REQUIRE_TEAM_INVITE: true
FEATURE_RESTRICTED_V1_PUSH: true
FEATURE_SECURITY_NOTIFICATIONS: false
FEATURE_SECURITY_SCANNER: false
FEATURE_STORAGE_REPLICATION: false
FEATURE_TEAM_SYNCING: false
FEATURE_USER_CREATION: true
FEATURE_USER_LAST_ACCESSED: true
FEATURE_USER_LOG_ACCESS: false
FEATURE_USER_METADATA: false
FEATURE_USER_RENAME: false
FEATURE_USERNAME_CONFIRMATION: true
FRESH_LOGIN_TIMEOUT: 10m
GITHUB_LOGIN_CONFIG: {}
GITHUB_TRIGGER_CONFIG: {}
GITLAB_TRIGGER_KIND: {}
LDAP_ALLOW_INSECURE_FALLBACK: false
LDAP_EMAIL_ATTR: mail
LDAP_UID_ATTR: uid
LDAP_URI: ldap://localhost
LOG_ARCHIVE_LOCATION: default
LOGS_MODEL: database
LOGS_MODEL_CONFIG: {}
MAIL_DEFAULT_SENDER: support@quay.io
MAIL_PORT: 587
MAIL_USE_AUTH: false
MAIL_USE_TLS: false
PREFERRED_URL_SCHEME: https
REGISTRY_TITLE: Project Quay
REGISTRY_TITLE_SHORT: Project Quay
REPO_MIRROR_INTERVAL: 30
REPO_MIRROR_TLS_VERIFY: true
SEARCH_MAX_RESULT_PAGE_COUNT: 10
SEARCH_RESULTS_PER_PAGE: 10
SECRET_KEY: f8204bde-3892-4500-aae5-4913026efa14
SECURITY_SCANNER_INDEXING_INTERVAL: 30
SERVER_HOSTNAME: localhost:80
SETUP_COMPLETE: true
TAG_EXPIRATION_OPTIONS:
    - 0s
    - 1d
    - 1w
    - 2w
    - 4w
TEAM_RESYNC_STALE_TIME: 30m
TESTING: false
USE_CDN: false
USER_EVENTS_REDIS:
    host: ${server_ip} 
    password: ${REDIS_PASSWORD}
    port: 6379
USER_RECOVERY_TOKEN_LIFETIME: 30m
USERFILES_LOCATION: default
EOF
) > $quay_config_filename

# Prepare local storage for image data
mkdir $QUAY_DIR/storage
setfacl -m u:1001:-wx $QUAY_DIR/storage

# Create a reusable script for launching quay
init_script $quay_script

(
cat <<EOF
podman container stop -i quay-server
podman container rm -i quay-server

podman run -d --rm -p 80:8080 -p 443:8443  \
   --name=quay-server \
   -v \$QUAY_DIR/config:/conf/stack:Z \
   -v \$QUAY_DIR/storage:/datastorage:Z \
   quay.io/projectquay/quay:v3.8.0
EOF
) >> $quay_script

# Deploy the Project Quay registry
$quay_script

####
## Rerun script

# Create a script for rerunning everything for instance if the server is shut down
init_script $rerun_script

(
cat <<EOF
# Turn off SELinux for now or else get memory permission errors
setenforce 0

$postgres_script
$redis_script
$quay_script
EOF
) >> $rerun_script
