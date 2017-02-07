#!/bin/bash

# We assume that the script is on $HOME
THIS_PATH=$(cd "$(dirname "$0")"; pwd -P)
exec docker run -it -v "$HOME:$HOME" robsyme/docker-sge "$THIS_PATH/setup_docker_and_login_sgeadmin.sh"

