# Docker scripts
这个项目包含几个实用的`docker`工具，能够让你更方便的使用`docker`。

主要包含的工具有：
* `docker_install.sh`: 安装docker到系统，并设置aliyun的镜像，直接以当前用户执行即可，如果有问题可以打开这个脚本看看里面的说明
* `docker_install_nvidia-docker2.sh`: 安装nvidia-docker2
* `docker_saveImage.sh`: 将docker image 或者 continer保存到本地文件
* `docker_loadImage.sh`: 将本地文件恢复到docker系统
* `docker_run.sh`: 创建/运行/删除docker执行环境

## 1. 安装docker
直接执行`./docker_install.sh`就可以，如果有问题，在 http://192.168.1.3/PI_LAB/docker_scripts/issues 反馈意见

如果希望在docker使用nvidia显卡，则需要安装nvidia-docker2，可以执行`./docker_install_nvidia-docker2.sh`


由于安装过程需要比较多网络操作，这些步骤很有可能使用脚本执行会有问题，所以需要根据问题仔细分析问题。如果遇到问题，可以查看`docker_install.sh`里面详细的解释。或者查看 [SummerCamp的docker教程](http://192.168.1.3/PI_LAB/SummerCamp2018/blob/master/tool/docker/content/install.md)。 



## 2. 创建一个docker镜像

由于`docker build`需要网络访问，所以网络上大多数教程的例子无法使用（可能是我的那个配置没有搞对）。**所以构建一个交互的docker，在环境里面进行安装软件等操作**。


需要将Dockerfile稍微改造一下，写成shell脚本，例如原来的安装pytorch的Dockerfile脚本`Dockerfile_pytorch`是：
```
## install pytorch

# update source list
cp ubuntu_16.04_sources_cn.list /etc/apt/sources.list
cp dot.vimrc /root/.vimrc


# Install dependencies
apt-get update -y
apt-get install software-properties-common -y

# All packages (Will install much faster)
RUN apt-get install --no-install-recommends -y git cmake python-pip build-essential 

# update pip mirror
RUN mkdir -p /root/.config/pip
COPY pip.conf /root/.config/pip/pip.conf

# for python 3
RUN apt-get install python3-pip

# pytorch (Python 3.5, CUDA 9.0)
RUN pip3 install http://download.pytorch.org/whl/cu90/torch-0.4.0-cp35-cp35m-linux_x86_64.whl 
RUN pip3 install torchvision
```

可以手动转换成`build_pytorch.sh`是：
```
## install pytorch

# update source list
cp ubuntu_16.04_sources_cn.list /etc/apt/sources.list
cp dot.vimrc /root/.vimrc


# Install dependencies
apt-get update -y
apt-get install software-properties-common -y

# All packages (Will install much faster)
apt-get install --no-install-recommends -y git cmake python-pip build-essential 

# update pip mirror
mkdir -p /root/.config/pip
cp pip.conf /root/.config/pip/pip.conf

# for python 3
apt-get install python3-pip

# pytorch (Python 3.5, CUDA 9.0)
pip3 install http://download.pytorch.org/whl/cu90/torch-0.4.0-cp35-cp35m-linux_x86_64.whl 
pip3 install torchvision
```

然后运行命令`docker_run.sh -b`, 具体的使用方法为：
```
# 创建一个新的docker运行环境
#   -b                  创建新的镜像
#   -i                  新docker image的名字
#   -s                  从那个docker image所谓初始的镜像 （默认是 ubuntu）
#   -m                  本地文件和docker文件分享的设置 （不是必须，默认是/home:/home 脚本的目录:/data

./docker_run.sh -b -i ubuntu_test -s ubuntu_dev
```

本次的例子是：
```
cd build_scripts
../docker_run.sh -b -i pytorch_test -s ubuntu_dev -m "-v `pwd`:/data" 

# 这是会进入docker的环境，然后进入docker里面的映射目录 /data
cd /data

# 然后执行安装pytorch的脚本
./build_pytorch.sh

# 如果安装好了之后就可以 输入 Ctrl+D或者exit，退出docker环境，制作的docker image就是pytorch_test
```



## 3. 运行一个docker镜像

为了能够使用图形化的程序，使用`docker_run.sh`能够自动设置一些常用的配置

具体的使用方法为：
```
# 运行一个docker环境
#   -r                  运行docker (如果不设置，则默认操作是 -r)
#   -i                  docker image的名字 (如果不设置，则默认为 `ubuntu_dev`)
#   -m                  本地文件和docker文件分享的设置 （不是必须，默认是/home:/home 脚本的目录:/data
#   --nvidia            是否使用nvidia-docker2

./docker_run.sh -r -i ubuntu_test
```

执行命令之后，会进入交互命令环境，如果按`ctrl-d`推出docker运行之后，会自动将container内容提交到docker image，并删除container。


### 3.1 关于`-m`本地文件和docker文件分享的设置
* 其中的`-v`表示一个目录映射
* 后面跟上 `host_dir:docker_dir`
 * `host_dir`就是本机的目录
 * `docker_dir`就是docker里面映射的目录

例如希望将当前目录映射到docker里面的`/data`则可以这样执行：
```
docker_run.sh -m "-v `pwd`:/data"
```

如果希望将一个给定目录`/mnt/a409`,映射到docker里面的`/mnt/a409`则可以这样执行：
```
docker_run.sh -m "-v /mnt/a409:/mnt/a409"
```


### 3.2 设置alias加快命令的执行

每次都输入比较长的命令效率不高，因此可以将常用的命令设置成alias，这样方便使用

例如在 `~/.bashrc`中加入下述设置，就可以仅仅输入别名`docker_run_ubuntu_dev`就能执行
```
alias docker_run_ubuntu_dev='/script_path/docker_run.sh -i ubuntu_dev -m "-v /home:/home -v /mnt/a409:/a409"'
```

### 3.3 GPU服务器（192.168.1.158）上的设置
在GPU服务器（192.168.1.158）上的`~/.bashrc` （/home/ubuntu/.bashrc）中设置了
```
export docker_run='/home/ubuntu/share/docker/docker_scripts/docker_run.sh'
```
这个意思是将`docker_run`变量设置成 `/home/ubuntu/share/docker/docker_scripts/docker_run.sh`，这样可以在命令行输入`$docker_run -i ubuntu_test`来快速执行“ubuntu_test”的docker镜像。


也可以在`～/.bashrc`中设置
```
alias docker_pytorch_liqing="$docker_run -i pytorch_liqing -m '-v /mnt/a409:/mnt/a409' --nvidia"
```
这样就可以在命令行直接运行`docker_pytorch_liqing`来执行pytorch_liqing文件

**需要注意的是，加入到`~/.bashrc`之后，需要关闭终端，再次打开一个新的终端设置的别名才能起作用**



## 4. docker镜像仓库的使用

本地修改后的镜像可以通过`docker_run.sh push`到本地的仓库，方便大家分享。具体使用方法可以参考[docker registry usage](docs/docker_registry.md)

本地使用的仓库没有https，所以需要在`/etc/docker/daemon.json`中确保有：`"insecure-registries":["192.168.1.3:5000"]`，否则无法正确访问。


### 4.1 如何列出本地镜像仓库中所有的镜像

```
$ ./docker_run.sh --repo

repositories of 192.168.1.3:5000:

{
    "repositories": [
        "machinelearning",
        "machinelearning_image",
        "nvidia/cuda",
        "pytorch",
        "pytorch_dev",
        "pytorch_liqing",
        "ubuntu",
        "ubuntu_dev_image",
        "ubuntu_gl",
        "v2/ubuntu"
    ]
}
```

### 4.2 如何pull一个镜像到本地

```
$ ./docker_run.sh --pull ubuntu_gl
```

### 4.3 如何push一个本地镜像到服务器

```
# 如何参考本地的镜像文件, 通过 docker images 能够列出本地的镜像
$ docker images

$ ./docker_run.sh --push pytorch_dev
```


## 5. 实验室已经安装的镜像的说明：

* `ubuntu_dev`: Ubuntu 16.04基础开发环境，安装了大多数的软件包，apt镜像已经设置成国内服务器
* `machinelearning`: 机器学习，操作系统是Ubuntu 16.04，安装了python, pytorch (0.4), scikit-learn等机器学习，支持nvidia 
* `pytorch`: 机器学习pytorch的镜像，操作系统是Ubuntu 16.04，安装了pytorch (0.4)，支持nvidia 


可以使用`ubuntu_dev`来制作CV方面的镜像，使用`machinelearning`来制作机器学习方面的镜像
