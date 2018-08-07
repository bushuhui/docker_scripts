#!/bin/bash

#
# Automatic install apt source and frequently used packages
#
# FIXME: only support Ubuntu 16.04, 14.04, Linux Mint 17, 18
#
# References:
#   https://linuxconfig.org/how-to-select-the-fastest-apt-mirror-on-ubuntu-linux
#   https://askubuntu.com/questions/37753/how-can-i-get-apt-to-use-a-mirror-close-to-me-or-choose-a-faster-mirror
#



################################################################################
# detect system type & change apt source
################################################################################

# detect user type & set the command line
user_name=`whoami`

if [[ "$user_name" = "root" ]]; then
    SUDO=""
    install_command="apt-get install -y"
else
    SUDO="sudo "
    install_command="sudo apt-get install -y"
fi



# get system type & add apt repository
SYS_TYPE=`lsb_release -cs`
echo ""; echo ""
echo "System code name: $SYS_TYPE"
echo ""; echo ""


# Support for Ubuntu
ubuntu_repo_mirror="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"

ubuntu_repo_setting="deb ${ubuntu_repo_mirror} ${SYS_TYPE} main restricted universe multiverse\n
deb ${ubuntu_repo_mirror} ${SYS_TYPE}-updates main restricted universe multiverse\n
deb ${ubuntu_repo_mirror} ${SYS_TYPE}-backports main restricted universe multiverse\n
\n
deb http://security.ubuntu.com/ubuntu/ ${SYS_TYPE}-security main restricted universe multiverse\n
deb http://archive.canonical.com/ubuntu/ ${SYS_TYPE} partner\n"

# Ubuntu 16.04 (xenial); 14.04 (trusty) 
list_ubuntu="xenial trusty"
for i in $list_ubuntu; do 
    if [[ "$SYS_TYPE" = "$i" ]]; then
        plist="/etc/apt/sources.list"
        
        $SUDO cp ${plist} ${plist}.backup
        echo -e $ubuntu_repo_setting | $SUDO tee ${plist}
    fi
done

# Support for Linux Mint
linuxmint_repo_mirror="https://mirrors.tuna.tsinghua.edu.cn/linuxmint/"

linuxmint_base=""
# LinuxMint 18.3 (sylvia), 18.2 (sonya), 18.1 (serena), 18 (sarah)
list_xenial="sylvia sonya serena sarah"
for i in $list_xenial; do 
    if [[ "$SYS_TYPE" = "$i" ]]; then
        linuxmint_base="xenial"
    fi
done

# LinuxMint 17.3 (rosa), 17.2 (rafaela), 17.1 (rebecca), 17 (qiana)
list_trusty="rosa rafaela rebecca qiana"
for i in $list_trusty; do 
    if [[ "$SYS_TYPE" = "$i" ]]; then
        linuxmint_base="trusty"
    fi
done

linuxmint_repo_settings="deb ${linuxmint_repo_mirror} $SYS_TYPE main upstream import backport\n
\n
deb ${ubuntu_repo_mirror} ${linuxmint_base} main restricted universe multiverse\n
deb ${ubuntu_repo_mirror} ${linuxmint_base}-updates main restricted universe multiverse\n
deb ${ubuntu_repo_mirror} ${linuxmint_base}-backports main restricted universe multiverse\n
\n
deb http://security.ubuntu.com/ubuntu/ ${linuxmint_base}-security main restricted universe multiverse\n
deb http://archive.canonical.com/ubuntu/ ${linuxmint_base} partner\n"

if [[ -n "$linuxmint_base" ]]; then
    plist="/etc/apt/sources.list.d/official-package-repositories.list"
    
    $SUDO cp $plist ${plist}.backup
    echo -e $linuxmint_repo_settings | $SUDO tee $plist
fi


# update package lists
$SUDO apt-get update
$SUDO apt-get upgrade -y



################################################################################
# ia32 support librays, frequently used packages, chinese support
################################################################################
$install_command ia32-libs*
$install_command ubuntu-restricted-extras
$install_command ibus-pinyin ibus-qt4

################################################################################
# building tools & librarys
################################################################################
$install_command vim-common vim-doc vim-gtk vim-scripts
$install_command kile

$install_command build-essential
$install_command bin86 kernel-package 
$install_command g++
$install_command libstdc++5

$install_command exuberant-ctags cscope
$install_command git tig
$install_command manpages-dev glibc-doc manpages-posix manpages-posix-dev
$install_command ack-grep
$install_command cmake cmake-gui
$install_command ghex glogg
$install_command minicom

$install_command libncurses5 libncurses5-dev
$install_command mesa-utils libglu1-mesa freeglut3 freeglut3-dev 
$install_command libxmu-dev libxmu-headers


# install qt4
$install_command libqt4-core libqt4-dev libqt4-gui qt4-doc qt4-designer 
$install_command libqt4-qt3support libqwtplot3d-qt4-0 libqwtplot3d-qt4-dev qt4-dev-tools qt4-qtconfig 
$install_command python-qt4 python-qt4-doc python-qt4-gl
$install_command libqglviewer-dev libqglviewer2-qt4

$install_command qtcreator qtcreator-plugin-cmake qtcreator-plugin-valgrind


# math & libs
$install_command liblapack-dev liblapack3 liblapacke-dev libeigen3-dev liblapack-pic
$install_command libsuitesparse-dev

$install_command beignet-dev nvidia-opencl-dev libclc-dev libopentk-cil-dev

$install_command libboost-all-dev
$install_command python-numpy python-fftw python-scipy python-scientific python-scitools
$install_command gnuplot-x11
$install_command libglew-dev glew-utils
$install_command libgomp1

$install_command libv4l-dev qv4l2 v4l-utils
$install_command libdc1394-22-dev libdc1394-utils

$install_command libgstreamer1.0-dev

$install_command libavformat-dev libavcodec-dev libavutil-dev libswscale-dev




################################################################################
# utils
################################################################################
$install_command sysv-rc-conf
$install_command openssh-server
$install_command samba autofs 
$install_command fusesmb fuse-exfat

# nfs
#$install_command nfs-kernel-server nfs-common portmap
#sudo dpkg-reconfigure portmap 
#sudo /etc/init.d/portmap restart

$install_command xfsprogs
$install_command p7zip-full p7zip-rar unrar lbzip2 pigz
$install_command pcmanfm
$install_command filezilla
$install_command encfs


$install_command gimp
$install_command geeqie
$install_command shutter kazam
$install_command mypaint


$install_command mc
$install_command terminator
$install_command multiget
$install_command ethtool
$install_command atop
$install_command netstat iftop nethogs vnstat


# archivement mount
$install_command libarchive-dev libfuse-dev libfuse2

# media player
$install_command ffmpeg
$install_command mplayer2 smplayer mplayer-fonts
$install_command audacious audacious-dev audacious-plugins

# thunderbird
$install_command thunderbird

# zimwiki
$install_command zim


################################################################################
# setup user dirs (~/.config/user-dirs.dirs)
################################################################################
#mdkir -p $HOME/tem 
#mkdir -p $HOME/downloads
#XDG_PUBLICSHARE_DIR="$HOME/tem/"
#XDG_DOWNLOAD_DIR="$HOME/downloads"
#XDG_MUSIC_DIR="$HOME/tem/"
#XDG_VIDEOS_DIR="$HOME/tem/"
#XDG_DESKTOP_DIR="$HOME/desktop/"
#XDG_DOCUMENTS_DIR="$HOME/doc/"
#XDG_TEMPLATES_DIR="$HOME/tem/"
#XDG_PICTURES_DIR="$HOME/tem/"

