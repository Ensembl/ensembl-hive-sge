#!/bin/bash

HIVE_SGE_LOCATION=$1
EHIVE_LOCATION=$2
DOCKER_NAME=${3:-ensemblorg/ensembl-hive-sge:2.4}

exec docker run -it -v "$EHIVE_LOCATION:/repo/ensembl-hive" -v "$HIVE_SGE_LOCATION:/repo/ensembl-hive-sge" "$DOCKER_NAME"

