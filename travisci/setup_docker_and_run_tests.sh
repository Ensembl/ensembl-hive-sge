#!/bin/bash

## This script has to run as root because "/sbin/my_init" (the init system
## of the Docker image) does things that require root permissions

# Stop the script at the first failure
set -e

echo "DEBUG: Environment of $0"; env; id; echo "END_DEBUG"

# Install some packages inside the container
apt-get update
# Taken from ensembl-hive's Dockerfile
apt-get install -y cpanminus git build-essential \
		  sqlite3 libdbd-sqlite3-perl postgresql-client libdbd-pg-perl mysql-client libdbd-mysql-perl libdbi-perl \
		  libcapture-tiny-perl libdatetime-perl libhtml-parser-perl libjson-perl libproc-daemon-perl \
		  libtest-exception-perl libtest-simple-perl libtest-warn-perl libtest-warnings-perl libtest-file-contents-perl libtest-perl-critic-perl libgraphviz-perl \
		  libgetopt-argvfile-perl libchart-gnuplot-perl libbsd-resource-perl
# Extra dependencies for ensembl-hive-sge
apt-get install -y libxml-simple-perl

# It seems that non-root users cannot execute anything from /home/travis
# so we copy the whole directory for the sgeadmin user
SGEADMIN_HOME=/home/sgeadmin
cp -a /home/travis/build/Ensembl/ensembl-hive-sge $SGEADMIN_HOME
SGE_CHECKOUT_LOCATION=$SGEADMIN_HOME/ensembl-hive-sge
chown -R sgeadmin: $SGE_CHECKOUT_LOCATION

# Install the missing dependencies (if any)
cpanm --installdeps --with-recommends $SGE_CHECKOUT_LOCATION/ensembl-hive
cpanm --installdeps --with-recommends $SGE_CHECKOUT_LOCATION

sudo --login -u sgeadmin $SGE_CHECKOUT_LOCATION/travisci/run_tests.sh

