## Ref:
* https://github.com/dperson/samba
* https://hub.docker.com/r/itsthenetwork/nfs-server-alpine/

## Samba
## Hosting a Samba instance

```
sudo docker run -it -p 139:139 -p 445:445 -d dperson/samba
```

OR set local storage:

```
sudo docker run -it --name samba -p 139:139 -p 445:445 \
            -v /path/to/directory:/mount \
            -d dperson/samba
```



### Start an instance creating users and shares:

```
sudo docker run -it -p 139:139 -p 445:445 -d dperson/samba \
            -u "example1;badpass" \
            -u "example2;badpass" \
            -s "public;/share" \
            -s "users;/srv;no;no;no;example1,example2" \
            -s "example1 private;/example1;no;no;no;example1" \
            -s "example2 private;/example2;no;no;no;example2"
```



# NFS

```
docker run -d --name nfs --privileged -v /some/where/fileshare:/nfsshare -e SHARED_DIRECTORY=/nfsshare itsthenetwork/nfs-server-alpine:latest
```

Add `--net=host` or `-p 2049:2049` to make the shares externally accessible via the host networking stack. This isn't necessary if using [Rancher](http://rancher.com/) or linking containers in some other way.

Adding `-e READ_ONLY=true` will cause the exports file to contain `ro` instead of `rw`, allowing only read access by the clients.

Adding `-e SYNC=true` will cause the exports file to contain `sync` instead of `async`, enabling synchronous mode. Check the exports man page for more information: <https://linux.die.net/man/5/exports>.

Due to the `fsid=0` parameter set in the **/etc/exports file**, there's no need to specify the folder name when mounting from a client. For example, this works fine even though the folder being mounted and shared is /nfsshare: