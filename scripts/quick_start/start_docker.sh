#!/bin/bash

# We assume that the script is on $HOME
THIS_PATH=$(dirname "$(readlink -f "$0")")
exec docker run -it -v "$HOME:$HOME" robsyme/docker-sge "$THIS_PATH/setup_docker_and_login_sgeadmin.sh"

