#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
CUR_DIR=$(dirname "$SCRIPT")

cd $CUR_DIR


# copy files to docker container
cp ubuntu_16.04_sources_cn.list /etc/apt/sources.list
cp dot.vimrc /root/.vimrc

mkdir -p /root/.config/pip
cp pip.conf /root/.config/pip/pip.conf

# update sources
apt-get update


# install base packages
install_cmd="apt-get install -y"

$install_cmd software-properties-common
$install_cmd git build-essential cmake cmake-gui git
$install_cmd git vim-common vim-doc vim-gtk vim-scripts
$install_cmd bin86 kernel-package
$install_cmd manpages-dev glibc-doc manpages-posix manpages-posix-dev

$install_cmd libqt4-core libqt4-dev libqt4-gui
$install_cmd libeigen3-dev 
$install_cmd libsuitesparse-dev
$install_cmd libboost-all-dev

$install_cmd net-tools iputils-ping
$install_cmd p7zip-full p7zip-rar unrar lbzip2 pigz