#!/bin/bash

# Stop the script at the first failure
set -e

# Install some packages inside the container
apt-get update
apt-get install -qqy sqlite3 libdbd-sqlite3-perl libdbi-perl libcapture-tiny-perl libxml-simple-perl libdatetime-perl libjson-perl libtest-exception-perl perl-modules libtest-warn-perl

# Place symlinks for ensembl-hive and ensembl-hive-sge in sgeadmin's home directory
SGEADMIN_HOME=/home/sgeadmin

HIVE_SGE_LOCATION=	# TODO: replace with the path on your machine
ln -s "$HIVE_SGE_LOCATION" "$SGEADMIN_HOME/ensembl-hive-sge"

# We need the matching branch of ensembl-hive
EHIVE_LOCATION=		# TODO: replace with the path on your machine
ln -s "$EHIVE_LOCATION" "$SGEADMIN_HOME/ensembl-hive"

# Make this more prominent
echo -e '\n*******************\n* You probably want to source ensembl-hive-sge/scripts/setup_environment.sh\n*******************\n'

login -f sgeadmin

