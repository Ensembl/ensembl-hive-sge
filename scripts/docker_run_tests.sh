#!/bin/bash

# Stop the script at the first failure
set -e

# Install some packages inside the container
apt-get update
#apt-get install -y sqlite3
apt-get install -qqy sqlite3 libdbd-sqlite3-perl libdbi-perl libcapture-tiny-perl libxml-simple-perl libdatetime-perl libjson-perl libtest-exception-perl perl-modules libtest-warn-perl

#sudo -u sgeadmin -E
#source /home/travis/build/muffato/ensembl-hive-sge/scripts/travis_run_tests.sh
TRAVIS_DIR=/home/travis
BUILD_DIR=$TRAVIS_DIR/build/muffato/ensembl-hive-sge
cd $BUILD_DIR
export EHIVE_ROOT_DIR=$PWD/ensembl-hive
export PERL5LIB=$EHIVE_ROOT_DIR/modules:$PWD/modules
export EHIVE_TEST_PIPELINE_URLS='sqlite:///ehive_test_pipeline_db'

groupadd -g 1000 travis
useradd -u 1000 -g 1000 -d /home/travis -s /bin/bash -c "Fake Travis" travis

echo print_env
su -ml -c env travis
echo before
ls -l /home/travis/build/muffato/ensembl-hive-sge/scripts/travis_run_tests.sh
#su -ml -c "prove -v $BUILD_DIR/t/" sgeadmin
su -c /home/travis/build/muffato/ensembl-hive-sge/scripts/travis_run_tests.sh sgeadmin
echo after

