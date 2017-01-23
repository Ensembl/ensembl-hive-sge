#!/bin/bash

# Stop the script at the first failure
set -e

# Install some packages inside the container
sudo apt-get update
#sudo apt-get install -y sqlite3
sudo apt-get install -qqy sqlite3 libdbd-sqlite3-perl libdbi-perl libcapture-tiny-perl libxml-simple-perl libdatetime-perl libjson-perl libtest-exception-perl perl-modules libtest-warn-perl

#sudo -u sgeadmin -E
#source /home/travis/build/muffato/ensembl-hive-sge/scripts/travis_run_tests.sh
#TRAVIS_DIR=/home/travis
#BUILD_DIR=$TRAVIS_DIR/build/muffato/ensembl-hive-sge
EHIVE_SGE_DIR=/home/travis/build/muffato/ensembl-hive-sge
#EHIVE_SGE_DIR=/home/matthieu/workspace/src/ensembl/ensembl-hive-sge
#cd $BUILD_DIR
export EHIVE_ROOT_DIR=$EHIVE_SGE_DIR/ensembl-hive
#export EHIVE_ROOT_DIR=/home/matthieu/workspace/src/hive/2.4
export PERL5LIB=$EHIVE_ROOT_DIR/modules:$EHIVE_SGE_DIR/modules
export EHIVE_TEST_PIPELINE_URLS='sqlite:///ehive_test_pipeline_db'

#groupadd -g 1000 travis
#useradd -u 1000 -g 1000 -d /home/travis -s /bin/bash -c "Fake Travis" travis

echo print_env
env
id
#su -ml -c env travis
echo before
#ls -l /home/travis/build/muffato/ensembl-hive-sge/scripts/travis_run_tests.sh
#su -ml -c "prove -v $BUILD_DIR/t/" sgeadmin
echo prove -rv $EHIVE_SGE_DIR/t
cd $EHIVE_SGE_DIR
ls
prove -rv t
#su -c /home/travis/build/muffato/ensembl-hive-sge/scripts/travis_run_tests.sh sgeadmin
#su -lc /home/matthieu/workspace/src/ensembl/ensembl-hive-sge/scripts/docker_run_tests.sh sgeadmin
echo after

