#!/bin/bash

exec docker run -it -v "$HOME:$HOME" docker-ehive-sge-test login -f sgeadmin

