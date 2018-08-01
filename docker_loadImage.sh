#!/bin/bash

# example command:
#   docker load < odm_dev.tar

show_usage()
{
cat << EOF
Usage: 
    ${0##*/} [docker image]

Load saved docker image file to docker system

EOF
}


if [[ $# -gt 0 ]]; then
    echo ""; echo ">>> load file: $1 ..."
    docker load < $1
else
    show_usage
    exit -1
fi

