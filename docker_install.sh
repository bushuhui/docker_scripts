#!/bin/bash

#
# Auto install docker through aliyun mirror
#
# 请参考docker使用教程：
#   http://192.168.1.3/PI_LAB/SummerCamp2018/blob/master/tool/docker/content/install.md
#   http://192.168.1.3/PI_LAB/SummerCamp2018/blob/master/tool/docker/content/prepare.md
#
# FIXME: this script only support LinuxMint (17, 18), and Ubuntu (14.04, 16.04)
#

# default registry server, please change this to your registry server
REGISTRY_SERVER='192.168.1.3:5000'


###############################################################################
# Step 1: remove old docker & install some requirements
###############################################################################

echo ""; echo ""
echo ">>> Step 1: remove old docker & install some requirements ..."
echo ""; echo ""

sudo apt-get remove -y docker docker-engine docker.io
sudo apt-get update

sudo apt-get install -y \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual
    
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common


###############################################################################
# Step 2: add aliyun mirrors
###############################################################################

echo ""; echo ""
echo ">>> Step 2: add aliyun mirrors ..."
echo ""; echo ""

curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

# get system type & add apt repository
SYS_TYPE=`lsb_release -cs`
echo ""; echo ""
echo "System code name: $SYS_TYPE"
echo ""; echo ""

is_support_system=""

# Ubuntu 16.04 (xenial); LinuxMint 18.3 (sylvia), 18.2 (sonya), 18.1 (serena), 18 (sarah)
list_xenial="xenial sylvia sonya serena sarah"
for i in $list_xenial; do 
    if [[ "$SYS_TYPE" = "$i" ]]; then
        sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu xenial stable"
        
        is_support_system="true"
    fi
done

# Ubuntu 14.04 (trusty); LinuxMint 17.3 (rosa), 17.2 (rafaela), 17.1 (rebecca), 17 (qiana)
list_trusty="trusty rosa rafaela rebecca qiana"
for i in $list_trusty; do 
    if [[ "$SYS_TYPE" = "$i" ]]; then
        sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu trusty stable"
        
        is_support_system="true"
    fi
done

if [[ ! -n "$is_support_system" ]]; then
    echo ""; echo ""
    echo ">>> WARN: Your system [$SYS_TYPE] is supported by this script!!!"
    echo ""; echo ""
    
    exit -1
fi


###############################################################################
# Step 3: install docker-ce
###############################################################################

echo ""; echo ""
echo ">>> Step 3: install docker-ce ..."
echo ""; echo ""


sudo apt-get update
sudo apt-get install -y docker-ce


###############################################################################
# Step 4: 将当前用户加入到docker组
###############################################################################

echo ""; echo ""
echo ">>> Step 4: 将当前用户加入到docker组 ..."
echo "  将用户加入组后需要log out并重新登录，这个时候运行docker时不用在前面添加sudo，"
echo "  如可直接运行docker run hello-world。"
echo ""; echo ""

#   将用户加入组后需要log out并重新登录，这个时候运行docker时不用在前面添加sudo，如可直接运行docker run hello-world。
sudo usermod -aG docker $USER


###############################################################################
# Step 5: Change to use docker mirror (aliyun)
###############################################################################

# 对于使用 systemd 的系统，用 systemctl enable docker 启用服务后，
#   编辑 /etc/systemd/system/multi-user.target.wants/docker.service 文件，
#   找到 ExecStart= 这一行，在这行最后添加加速器地址 --registry-mirror=<加速器地址>，如：
#   ExecStart=/usr/bin/dockerd --registry-mirror=https://jxus37ad.mirror.aliyuncs.com
#
# 对于使用 upstart 的系统而言，编辑 /etc/default/docker 文件，在其中的 DOCKER_OPTS 中添加获得的加速器配置 --registry-mirror=<加速器地址>，如：
#   DOCKER_OPTS="--registry-mirror=https://jxus37ad.mirror.aliyuncs.com"
# 重新启动服务。
#   $ sudo service docker restart

echo ""; echo ""
echo ">>> Step 5: Change to use docker mirror (aliyun) ..."
echo "  using aliyum mirror: https://jxus37ad.mirror.aliyuncs.com"
echo ""; echo ""

sudo systemctl enable docker

# FIXME: assume /etc/systemd/system/multi-user.target.wants/docker.service -> /lib/systemd/system/docker.service
fp='/etc/systemd/system/multi-user.target.wants/docker.service'
if [[ -e $fp ]]; then
    lc=`readlink $fp`
    fp2=$fp
    if [[ ! "$lc" = "" ]]; then
        fp2=$lc
    fi
    
    sudo sed 's/ExecStart=.*/ExecStart=\/usr\/bin\/dockerd --registry-mirror=https:\/\/jxus37ad.mirror.aliyuncs.com/g' -i $fp2
else
    echo ""; echo "";
    echo "Can not find docker.service file."
    echo "!!! Please add mrror manual !!!"
    echo ""; echo ""
fi

f2="/etc/default/docker"
if [[ -e $f2 ]]; then
    echo 'DOCKER_OPTS="--registry-mirror=https://jxus37ad.mirror.aliyuncs.com"' | sudo tee -a $f2
    sudo service docker restart
fi


sudo systemctl daemon-reload
sudo systemctl restart docker

# 在命令行执行 ps -ef | grep dockerd，如果从结果中看到了配置的 --registry-mirror 参数说明配置成功。
echo ""; echo ""
echo "请确认看到 --registry-mirror=https://jxus37ad.mirror.aliyuncs.com"
ps -ef | grep dockerd
echo ""; echo ""



# 设置registry server
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
# Step 6: 修改Docker默认储存位置
###############################################################################

echo ""; echo ""
echo ">>> Step 6: 修改Docker默认储存位置 ..."
echo ""
echo ""
echo "docker的使用过程中会产生大量的文件，所以有必要把docker默认的存储位置改一下"
echo "1. 使用docker info查看docker的基本信息。"
echo "   docker info"
echo "2. 停止 Docker 服务"
echo "   sudo /etc/init.d/docker stop"
echo "3. 将原来默认的/var/lib/docker备份一下，然后复制到别的位置并建立一个软链接"
echo "   cd /var/lib"
echo "   sudo mv docker <my_new_location>"
echo "   sudo ln -s <my_new_location>/docker docker"
echo "4. 启动 Docker 服务"
echo "   sudo /etc/init.d/docker start"
echo "5. 最后使用 docker info 查看更新结果:"
echo "   docker info"



