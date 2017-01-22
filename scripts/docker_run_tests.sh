#!/bin/bash

# Stop the script at the first failure
set -e

# Install some packages inside the container
apt-get update
apt-get install -y sqlite3
#apt-get install -y sqlite3 libdbd-sqlite3-perl libdbi-perl libcapture-tiny-perl libxml-simple-perl libdatetime-perl libjson-perl libtest-exception-perl perl-modules libtest-warn-perl

#sudo -u sgeadmin -E
source /home/travis/build/muffato/ensembl-hive-sge/scripts/travis_run_tests.sh
TRAVIS_DIR=/home/travis
BUILD_DIR=$TRAVIS_DIR/build/muffato/ensembl-hive-sge/
cd $BUILD_DIR
export EHIVE_ROOT_DIR=$PWD/ensembl-hive
export PERL5LIB=$EHIVE_ROOT_DIR/modules:$PWD/modules
export EHIVE_TEST_PIPELINE_URLS='sqlite:///ehive_test_pipeline_db'
export PATH=$TRAVIS_DIR/perl5/perlbrew/bin:$TRAVIS_DIR/perl5/perlbrew/perls/5.10/bin:$TRAVIS_DIR/bin::$TRAVIS_DIR/.local/bin::$PATH
export HOME=/home/sgeadmin

echo print_env
sudo -u sgeadmin -E env
echo before
sudo -u sgeadmin -E prove -rv $BUILD_DIR/t
echo after

