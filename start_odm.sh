#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
CUR_DIR=$(dirname "$SCRIPT")

cd $CUR_DIR


# check docker installed?
C=`docker --version`
if [[ "$C" = "" ]]; then
    echo ""; echo "Install docker ..."
    $CUR_DIR/docker_install.sh
fi


# check docker image loaded?
C=`docker images -a | grep odm_dev`
if [[ "$C" = "" ]]; then
    echo ""; echo "Load OpenDroneMap docker image ..."
    docker load < odm_dev.tar 
fi


# check dirs exist
if [[ ! -d $CUR_DIR/OpenDroneMap ]]; then
    echo ""; echo "Extracting OpenDroneMap data ..."
    tar xzf OpenDroneMap.tar.gz
fi

if [[ ! -d $CUR_DIR/sample_data ]]; then
    echo ""; echo "Extracting sample data ..."
    tar xf sample_data.tar
fi

if [[ ! -d $CUR_DIR/projects ]]; then
    mkdir projects
fi


# check container is exist & run the container
C=`docker ps -a | grep odm_dev`
if [[ "$C" = "" ]]; then
    xhost +
    docker run -it -h "odm" \
        --net=host --privileged \
        -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v /home:/home -v $CUR_DIR:/OpenDroneMap_docker \
        --name odm odm_dev \
        /autostart.sh
else
    echo "Please press [Enter] to see the prompt!"
    docker start odm
    docker attach odm
fi

