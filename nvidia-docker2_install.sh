#!/bin/bash

# Auto install docker through aliyun mirror
# 请参考docker使用教程：
#   http://192.168.1.3/PI_LAB/SummerCamp2018/blob/master/tool/docker/content/install.md
#   http://192.168.1.3/PI_LAB/SummerCamp2018/blob/master/tool/docker/content/prepare.md
#   http://192.168.1.3/PI_LAB/SummerCamp2018/blob/master/tool/docker/content/nvidia-docker2.md
#
# FIXME: this script only support LinuxMint (18), and Ubuntu (16.04)


# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
CUR_DIR=$(dirname "$SCRIPT")


# Step 1: check docker installed?
C=`docker --version`
if [[ "$C" = "" ]]; then
    echo ""; echo "Install docker ..."
    $CUR_DIR/docker_install.sh
fi


# Step 2: check system

SYS_TYPE=`lsb_release -cs`
echo ""; echo ""
echo "System code name: $SYS_TYPE"


SYS_OK=0

# LinuxMint 18.3 (sylvia), 18.2 (sonya), 18.1 (serena), 18 (sarah)
if [[ "$SYS_TYPE" = "sylvia" ]] || [[ "$SYS_TYPE" = "sonya" ]] || [[ "$SYS_TYPE" = "serena" ]] || [[ "$SYS_TYPE" = "sarah" ]]; then
    SYS_OK=1
fi

# Ubuntu 16.04 (xenial)
if [[ "$SYS_TYPE" = "xenial" ]]; then
    SYS_OK=1
fi

if [[ "$SYS_OK" = "0" ]]; then
    echo "Please use this script on Ubuntu 16.04 or LinuxMint 18"
    exit 0
fi


# Step 3: setup source
echo ""; echo ""
echo "Setup nvidia-docker2 ..."
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update


sudo apt-get install nvidia-docker2
sudo pkill -SIGHUP dockerd


# Step 4: demo usage
docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi

