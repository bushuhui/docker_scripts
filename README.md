# Docker scripts
This project contains some useful docker scripts and commands, which help you to use docker smoothly.


## create the docker file 
```
docker build -t pytorch . 
```


## install pytorch
https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/linux-64/

PIP, Python 3.5, CUDA 9.0
```
pip3 install http://download.pytorch.org/whl/cu90/torch-0.4.0-cp35-cp35m-linux_x86_64.whl 
pip3 install torchvision
```


## using docker registry

please refer [docker registry usage](docs/docker_registry.md)

