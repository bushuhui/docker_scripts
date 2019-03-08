#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
CUR_DIR=$(dirname "$SCRIPT")

# gitlab
#   https://docs.gitlab.com/omnibus/docker

docker run --detach \
    --hostname gitlab.example.com \
    --publish 20443:443 --publish 2080:80 --publish 2022:22 \
    --name gitlab \
    --restart always \
    --volume $CUR_DIR/gitlab-data/config:/etc/gitlab \
    --volume $CUR_DIR/gitlab-data/logs:/var/log/gitlab \
    --volume $CUR_DIR/gitlab-data/data:/var/opt/gitlab \
    gitlab/gitlab-ce
