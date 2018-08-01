#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
CUR_DIR=$(dirname "$SCRIPT")


included="true"

# the source image
image_from="ubuntu:16:04"

# this docker's image
docker_image="ubuntu_dev"
# the container's name
docker_container=""


# path mapping for host<->docker
user_pwd=`pwd`
path_mapping="-v /home:/home -v $user_pwd:/data"

# commit docker container to image
opt_commit_dockerimage="true"
# auto remove docker container
opt_auto_rm_container="true"


# include docker_run script
source $CUR_DIR/docker_run.sh
