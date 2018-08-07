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

如果希望在docker使用nvidia显卡，则需要安装nvidia-docker2，可以执行`docker_install_nvidia-docker2.sh`

## 2. 创建一个docker镜像

由于`docker build`需要网络访问，所以网络上大多数教程的例子无法使用（可能是我的那个配置没有搞对）。所以构建一个交互的docker，在环境里面进行安装软件等操作。

具体的使用方法为：
```
# 创建一个新的docker运行环境
#   -b                  创建新的镜像
#   -i                  新docker image的名字
#   -s                  从那个docker image所谓初始的镜像 （默认是 ubuntu）

./docker_run.sh -b -i ubuntu_test -s ubuntu_dev
```

## 3. 运行一个docker镜像

为了能够使用图形化的程序，使用`docker_run.sh`能够自动设置一些常用的配置

具体的使用方法为：
```
# 运行一个docker环境
#   -r                  运行docker (如果不设置，则默认操作是 -r)
#   -i                  docker image的名字 (如果不设置，则默认为 `ubuntu_dev`)
#   -m                  本地文件和docker文件分享的设置 （不是必须，默认是/home:/home 脚本的目录:/data

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

需要注意的是，加入到`~/.bashrc`之后，需要关闭终端，再次打开一个新的终端设置的别名才能起作用



## 4. docker镜像仓库的使用

本地修改后的镜像可以通过`docker push`到本地的仓库，方便大家分享。具体使用方法可以参考[docker registry usage](docs/docker_registry.md)

