#!/bin/bash

# start docker registry service

docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v /data/docker_registry:/var/lib/registry \
  registry:2
