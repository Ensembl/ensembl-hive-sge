#!/bin/bash

set -e

apt-get update
apt-get install -y libxml-simple-perl

# Cleanup the cache to reduce the disk footprint
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

