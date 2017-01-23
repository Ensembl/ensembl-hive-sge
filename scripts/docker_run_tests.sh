#!/bin/bash

## This script runs as root

# Stop the script at the first failure
set -e

# Install some packages inside the container
apt-get update
apt-get install -qqy sqlite3 libdbd-sqlite3-perl libdbi-perl libcapture-tiny-perl libxml-simple-perl libdatetime-perl libjson-perl libtest-exception-perl perl-modules libtest-warn-perl

# It seems that non-root users cannot execute anything from /home/travis
# so we copy the whole directory for the sgeadmin user
SGEADMIN_HOME=/home/sgeadmin
cp -a /home/travis/build/muffato/ensembl-hive-sge $SGEADMIN_HOME
chown -R sgeadmin: $SGEADMIN_HOME/ensembl-hive-sge
sudo --login -u sgeadmin $SGEADMIN_HOME/ensembl-hive-sge/scripts/travis_run_tests.sh

