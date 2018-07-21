#!/bin/bash

# save odm_dev image
docker commit odm odm_dev
docker save odm_dev -o odm_dev.tar


