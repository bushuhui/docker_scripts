#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
CUR_DIR=$(dirname "$SCRIPT")

cd $CUR_DIR

image_from="ubuntu:16:04"

docker_image="ubuntu_dev_image"
docker_container="ubuntu_dev"

# check container is exist & run the container
C=`docker ps -a | grep $docker_container`
if [[ "$C" = "" ]]; then
    xhost +
    docker run -it -h "$docker_container" \
        --net=host --privileged \
        -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v /home:/home -v $CUR_DIR:/data \
        --name $docker_container $docker_image \
        bash
else
    echo "Please press [Enter] to see the prompt!"
    docker start  $docker_container
    docker attach $docker_container
fi

