#!/bin/bash

# Auto install nvidia-docker2 
#
# 请参考docker使用教程：
#   http://192.168.1.3/PI_LAB/SummerCamp2018/blob/master/tool/docker/content/install.md
#   http://192.168.1.3/PI_LAB/SummerCamp2018/blob/master/tool/docker/content/prepare.md
#   http://192.168.1.3/PI_LAB/SummerCamp2018/blob/master/tool/docker/content/nvidia-docker2.md
#
# FIXME: this script only support LinuxMint (18), and Ubuntu (16.04)
#

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
CUR_DIR=$(dirname "$SCRIPT")

###############################################################################
# Step 0: Install nvidia driver & cuda
###############################################################################
echo ""; echo ""
echo ">>> Step 0: Please install Nvidia driver & cuda correctly ..."
echo "     pleaes see the document for download & install: https://developer.nvidia.com/cuda-downloads "
echo ""; echo ""


###############################################################################
# Step 1: check docker installed?
###############################################################################

echo ""; echo ""
echo ">>> Step 1: check docker installed? ..."
echo ""; echo ""

C=`docker --version`
if [[ "$C" = "" ]]; then
    echo ""; echo "Install docker ..."
    $CUR_DIR/docker_install.sh
fi


###############################################################################
# Step 2: check system
###############################################################################

SYS_TYPE=`lsb_release -cs`

echo ""; echo ""
echo ">>> Step 2: check system ..."
echo ""; echo ""

echo "System code name: $SYS_TYPE"
echo ""; echo ""


SYS_OK=0

# Ubuntu 16.04 (xenial); LinuxMint 18.3 (sylvia), 18.2 (sonya), 18.1 (serena), 18 (sarah)
list_xenial="xenial sylvia sonya serena sarah"
for i in $list_xenial; do 
    if [[ "$SYS_TYPE" = "$i" ]]; then
        SYS_OK=1
    fi
done


if [[ "$SYS_OK" = "0" ]]; then
    echo ""; echo ""
    echo ">>> ERR: Please use this script on Ubuntu 16.04 or LinuxMint 18"
    exit 0
fi


###############################################################################
# Step 3: setup nvidia-docker2
###############################################################################

echo ""; echo ""
echo ">>> Step 3: setup nvidia-docker2 ..."
echo ""; echo ""

curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update


sudo apt-get install -y nvidia-docker2


# 设置registry server
#   default registry server, please change this to your registry server
REGISTRY_SERVER='192.168.1.3:5000'

reg_settings='{
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },

    "insecure-registries":["'$REGISTRY_SERVER'"]
}'

echo $reg_settings | sudo tee /etc/docker/daemon.json
sudo /etc/init.d/docker restart


###############################################################################
# Step 4: test nvidia-docker2 install correct or not?
###############################################################################

echo ""; echo ""
echo ">>> Step 4: test nvidia-docker2 install correct or not? ..."
echo ""; echo ""

docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi

