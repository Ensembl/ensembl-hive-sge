#!/bin/bash

# Stop the script at the first failure
set -e

# Install some packages inside the container
apt-get update
apt-get install -y sqlite3
#apt-get install -y sqlite3 libdbd-sqlite3-perl libdbi-perl libcapture-tiny-perl libxml-simple-perl libdatetime-perl libjson-perl libtest-exception-perl perl-modules libtest-warn-perl

exec sudo -u sgeadmin -E "$BUILD_DIR/scripts/travis_run_tests.sh"

