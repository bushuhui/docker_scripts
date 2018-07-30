# Docker private registry

## Create/run a registry on local computer

On the server (IP address is `192.168.1.3`), run the following command, or add it to `/etc/rc.local` to start it automatically
```
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```


## Copy an image to local registry

1. Download a docker image from docker hub or mirrors:
```
$ docker pull ubuntu:16.04
```

2. Tag the image as `192.168.1.3:5000/ubuntu`. This creates an additional tag for the existing image. When the first part of the tag is a hostname and port, Docker interprets this as the location of a registry, when pushing.
```
$ docker tag ubuntu:16.04 192.168.1.3:5000/ubuntu
```


3. Push the image to the local registry running at `192.168.1.3:5000`:
```
$ docker push 192.168.1.3:5000/ubuntu
```

4. Remove the locally-cached `ubuntu` and `192.168.1.3:5000/ubuntu` images, so that you can test pulling the image from your registry. This does not remove the `192.168.1.3:5000/ubuntu` image from your registry.
```
$ docker image remove ubuntu
$ docker image remove 192.168.1.3:5000/ubuntu
```

5. Pull the docker image in the registry to local:
```
$ docker pull 192.168.1.3:5000/ubuntu
```

**NOTE**: The default registry do not support HTTPS, so it is necessary to add a configuration into you `/etc/docker/daemon.json`

```
{ "insecure-registries":["192.168.1.3:5000"] }
```

After add the line, then restart the docker through `sudo /etc/init.d/docker restart`


## docker中镜像的命名规则

docker中镜像的命名规则，如：registry.domain.com/mycom/base:latest，这是一个完整的image名称，下面说下各部分的作用

* `registry.domain.com`： image所在服务器地，如果是官方的hub部分忽略
* `mycom：namespace`，被称为命名空间，或者说成是你镜像的一个分类
* `base`： 这个是镜像的具体名字
* `latest`： 这是此image的版本号，当然也可能是其它的，如1.1之类的



## How to list images in the registry?

Access the following address `http://<ip/hostname>:<port>/v2/_catalog`

For example: 
```
http://192.168.1.3:5000/v2/_catalog
```

Get tag of an image:
```
http://192.168.1.3:5000/v2/ubuntu/tags/list
```


## References
* https://docs.docker.com/registry/deploying/#storage-customization
* http://www.cnblogs.com/xguo/p/3829329.html
