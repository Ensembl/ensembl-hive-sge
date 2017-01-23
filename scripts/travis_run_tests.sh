#!/bin/bash

# Stop the script at the first failure
set -e

echo "in_script"
env
id

TRAVIS_DIR=/home/travis
BUILD_DIR=$TRAVIS_DIR/build/muffato/ensembl-hive-sge
cd $BUILD_DIR
export EHIVE_ROOT_DIR=$PWD/ensembl-hive
export PERL5LIB=$EHIVE_ROOT_DIR/modules:$PWD/modules
export EHIVE_TEST_PIPELINE_URLS='sqlite:///ehive_test_pipeline_db'
export PATH=$TRAVIS_DIR/perl5/perlbrew/perls/5.10/bin:$PATH

echo before
ls -l t
prove -rv t
echo after

