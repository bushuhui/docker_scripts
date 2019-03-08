#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
CUR_DIR=$(dirname "$SCRIPT")

#docker stop nginx; docker rm nginx

docker run \
  --name nginx \
  --restart=always \
  -d -p 8000:80 \
  -v $CUR_DIR/config:/etc/nginx/conf.d \
  -v /mnt/a409/share:/www \
  nginx
  
