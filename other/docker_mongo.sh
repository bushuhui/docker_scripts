#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
CUR_DIR=$(dirname "$SCRIPT")

# mongodb
#   https://hub.docker.com/r/bitnami/mongodb/
#
# Setting the root password on first run
#   Passing the MONGODB_ROOT_PASSWORD environment variable when running the image for the first time 
#   will set the password of the root user to the value of MONGODB_ROOT_PASSWORD and enabled authentication 
#   on the MongoDB server.
#

docker run -d \
    --restart always \
    --name mongodb \
    -p 27017:27017 \
    -v $CUR_DIR/mongodb_data:/data/db \
    mongo

# mongo-express
#   https://docs.docker.com/samples/library/mongo-express
#
#    -e ME_CONFIG_OPTIONS_EDITORTHEME="ambiance" \
#    -e ME_CONFIG_BASICAUTH_USERNAME="user" \
#    -e ME_CONFIG_BASICAUTH_PASSWORD="fairly long password" \
#
docker run -d \
    --restart always \
    --name mongo-express \
    --link mongodb:mongo \
    -p 8081:8081 \
    mongo-express
