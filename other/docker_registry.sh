#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
CUR_DIR=$(dirname "$SCRIPT")

docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name docker_registry \
  -v $CUR_DIR/data:/var/lib/registry \
  registry:2

