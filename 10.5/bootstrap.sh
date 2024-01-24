#!/usr/bin/env bash

# Install PostgreSQL
# Based on: https://wiki.postgresql.org/wiki/PostgreSQL_For_Development_With_Vagrant


# Edit the following to change the version of PostgreSQL that is installed
PG_VERSION=8.4

# Add PG apt repo:
PG_REPO_APT_SOURCE=/etc/apt/sources.list.d/pgdg.list
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > "$PG_REPO_APT_SOURCE"
# Add PGDG repo key:
wget --quiet -O - https://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -

# Update repositories
apt-get update

echo "Start"
# Instal PostgreSQL
apt-get install -y "postgresql-$PG_VERSION" "postgresql-contrib-$PG_VERSION"

# Install Server Instrumentation
sudo -u postgres psql -c "CREATE EXTENSION adminpack;"

# Set password, we will not be able to access the server externally otherwise
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"

################################################################################
#                             POSTGRESQL CONFIGS                               #
################################################################################

# Find important files that need to be modified
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_DIR="/var/lib/postgresql/$PG_VERSION/main"

# Edit postgresql.conf to change listen address to '*':
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

# Append to pg_hba.conf to add password auth:
echo "host    all             all             all                     md5" >> "$PG_HBA"

# Explicitly set default client_encoding
echo "client_encoding = utf8" >> "$PG_CONF"

# Restart so that all new config is loaded:
service postgresql restart
################################################################################

# Make sure everything's up to date
apt-get upgrade -y
