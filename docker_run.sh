#!/bin/bash

###############################################################################
###############################################################################
# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
CUR_DIR=$(dirname "$SCRIPT")


###############################################################################
###############################################################################

print_usage()
{
cat << EOF
Usage: 
    ${0##*/} 
        [-r] [-b] [-d] [-h]
        [--repo] [--pull] [--push]
        [--images] [--ps]
        [--save image] [--load image]
        [-i IMAGE] [-s SOURCE IMAGE] [-c CONTAINER] 
        [-m PATH_MAPPING]
        [--auto_commit true/false] 
        [--auto_rm_container true/false]
        [--nvidia]
        [--cmd "command line"]

Create/Run/Delete docker container from image

  Acts:
    -r, --run           Run the container
    -b, --build         Build a docker image from given image
    -d, --delete        Delete a docker container
    
    --commit            Commit the container to image
    
    --repo              List registry repositories
    --pull              Pull a registry image
    --push              Push local image to registry
    
    --images            List all docker images
    --ps                List containers
    
    --save              Save image to file
    --load              Load file to restore image
  
    -h, --help          Display this help and exit.

  Opts:
    -i, --image         Required. Set the name of the image.
    -s, --source        Required. Set the source image
    -c, --container     Required. Set the container name
    -m, --mapping       Required. Path mapping (host<->docker)
    --auto_commit       Auto commit docker container to image (Default: false)
    --auto_rm_container Auto remove docker container (Default: false)
    --nvidia            Run as nvidia-docker2 (Default: not set)
    --cmd               Required. The command which container will run
    
EOF
}


###############################################################################
# Default settings
###############################################################################
if [[ -z "$included" ]]; then
    # the source image
    image_from="ubuntu"

    # this docker's image
    docker_image="ubuntu_dev"
    # the container's name
    docker_container=""

    # path mapping for host<->docker
    user_pwd=`pwd`
    path_mapping="-v /home:/home -v $user_pwd:/data"


    # commit docker container to image
    opt_auto_commit_dockerimage="false"
    # auto remove docker container
    opt_auto_rm_container="false"
    # nvidia-docker2 or not
    opt_nvidia_docker2="false"
    
    # default command 
    opt_command="bash"
fi

# regitry server address
opt_registry_server="192.168.1.3:5000"




###############################################################################
###############################################################################

# build a docker image from a source image
build_docker_image()
{
    echo ">>> Build a docker image [$docker_image] from [$image_from]"; echo ""
    
    # check container is exist
    C=`docker ps -a | grep $docker_container`
    if [[ -n "$C" ]]; then
        echo "WARN: docker container: [$docker_container] exist, so please confirm to delete it"
        echo "      docker rm $docker_container"
        exit -1
    fi
    
    # check the image is exist
    C=`docker images | grep $docker_image`
    if [[ -n "$C" ]]; then
        echo "WARN: docker image: [$docker_image] exist, so please confirm to delete it"
        echo "      docker rmi $docker_image"
        exit -1
    fi
    
    # get nvidia-docker2 opts
    nvidia_docker_opts=""
    if [[ "$opt_nvidia_docker2" = "true" ]]; then
        nvidia_docker_opts="--runtime=nvidia"
    fi
    
    # command
    if [[ -n "$opt_command" ]]; then
        opt_command="bash"
    fi
    
    # run the docker from given source image
    xhost +
    docker run -it $nvidia_docker_opts \
            -h "$docker_image" \
            --net=host --privileged \
            -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
            $path_mapping \
            --name $docker_container $image_from \
            $opt_command

    docker commit $docker_container $docker_image
    
    # auto rm docker container
    if [[ "$opt_auto_rm_container" = "true" ]]; then
        docker rm $docker_container
    fi
}

# run the docker image
run_docker_container()
{
    # check container is exist & run the container
    C=`docker ps -a | grep $docker_container`
    if [[ "$C" = "" ]]; then
    
        # get nvidia-docker2 opts
        nvidia_docker_opts=""
        if [[ "$opt_nvidia_docker2" = "true" ]]; then
            nvidia_docker_opts="--runtime=nvidia"
        fi
        
        # command
        if [[ -n "$opt_command" ]]; then
            opt_command="bash"
        fi
        
        echo ">>> Run a docker container [$docker_container] from [$docker_image]"; echo ""
            
        xhost +
        docker run -it $nvidia_docker_opts \
            -h "$docker_image" \
            --net=host --privileged \
            -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
            $path_mapping \
            --name $docker_container $docker_image \
            $opt_command

        # commit docker container to image
        if [[ "$opt_auto_commit_dockerimage" = "true" ]]; then
            docker commit $docker_container $docker_image
        fi
        
        # auto rm docker container
        if [[ "$opt_auto_rm_container" = "true" ]]; then
            docker rm $docker_container
        fi
    else
        echo ">>> The last container is exist. Please confirm to commit it and run a fresh-new container!"
        read -p "    Do you want to commit '$docker_container' to '$docker_image'   y/[n]: " docommit
        echo ""
        
        regexp="[Yy]+"
        if [[ "$docommit" =~ $regexp ]]; then
            # commit docker container to image
            docker commit $docker_container $docker_image
            
            # remove given continer
            docker rm $docker_container
            
            # run this function again
            run_docker_container
        else
            echo ">>> Run a docker container [$docker_container] from [$docker_image]"; echo ""
                
            echo ">>> WARN: after you reboot the computer, the GUI can not be used."
            echo "          So please consider to delete the continer first for using GUI"
            echo ""
            echo "Please press [Enter] to see the prompt! "
            
            docker start  $docker_container
            docker attach $docker_container
        fi
    fi
}

# delete a docker container
rm_docker_container()
{
    echo ">>> Delete a docker container [$docker_container]"; echo ""
    
    C=`docker ps -a | grep $docker_container`
    if [[ -n "$C" ]]; then
        # commit docker container to image
        if [[ "$opt_auto_commit_dockerimage" = "true" ]]; then
            docker commit $docker_container $docker_image
        fi
        
        # remove given continer
        docker rm $docker_container
    fi
}

# commit docker container to image
commit_docker_container()
{
    echo ">>> Commit a docker container [$docker_container] -> image [$docker_image]"; echo ""
    
    docker commit $docker_container $docker_image
} 


# save docker image to file
saveImage()
{
    echo ">>> save a docker image [$docker_image] -> local file"; echo ""
    docker save "$docker_image" -o "${docker_image}.tar"
} 

# load docker image from a file
loadImage()
{
    echo ">>> load a file [${docker_image}.tar] -> docker image [$docker_image]"; echo ""
    docker load < "${docker_image}.tar"
} 


###############################################################################
###############################################################################

# parse input arguments
params="$(getopt -o rbdhi:s:c:m: -l run,build,delete,help,image:,source:,container:,mapping:,auto_commit:,auto_rm_container:,nvidia,repo,pull:,push:,commit,save,load,cmd:,images,ps --name "$0" -- "$@")"
eval set -- "$params"
act="run"

while [[ $# -gt 0 ]] ; do
    case $1 in
        -h|-\?|--help)
            print_usage
            exit 0
            ;;
            
        -r|--run)  
            act="run"
            ;;
        -b|--build)
            act="build"
            ;;
        -d|--delete)
            act="delete"
            ;;
            
        --commit)
            act="commit"
            ;;
            
            
        --repo)
            repo=`curl -s http://$opt_registry_server/v2/_catalog`
            
            echo "repositories of $opt_registry_server:"; echo ""
            echo $repo | python -m json.tool
            
            exit 0
            ;;
            
        --pull)
            if [ -n "$2" ]; then
                repname=$2
                shift
                
                imagename="${opt_registry_server}/$repname"
                docker pull $imagename
                docker tag $imagename $repname
               
                exit 0
            else
                print_usage
                exit -1
            fi
            ;;

        --push)
            if [ -n "$2" ]; then
                repname=$2
                shift
                
                imagename="${opt_registry_server}/$repname"
                docker tag $repname $imagename
                docker push $imagename
               
                exit 0
            else
                print_usage
                exit -1
            fi
            ;;
            
            
        --save)
            act="save"
            ;;
            
        --load)
            act="load"
            ;;
            
        --images)
            docker images
            exit 0
            ;;
        --ps)
            docker ps -a
            exit 0
            ;;
            
            
        -i|--image)
            if [ -n "$2" ]; then
                docker_image=$2
                shift
            fi
            ;;
        -s|--source)
            if [ -n "$2" ]; then
                image_from=$2
                shift
            fi
            ;;
        -c|--container)
            if [ -n "$2" ]; then
                docker_container=$2
                shift
            fi
            ;;
        -m|--mapping)
            if [ -n "$2" ]; then
                path_mapping=$2
                shift
            fi
            ;;
        --auto_commit)
            if [ -n "$2" ]; then
                opt_auto_commit_dockerimage=$2
                shift
            fi            
            ;;
        --auto_rm_container)
            if [ -n "$2" ]; then
                opt_auto_rm_container=$2
                shift
            fi
            ;;
        --nvidia)
            opt_nvidia_docker2="true"
            ;;
        --cmd)
            if [ -n "$2" ]; then
                opt_command=$2
                shift
            fi
            ;;
    esac
    
    shift
done

# set default docker container name
if [[ -z "$docker_container" ]]; then
    # replace '/' -> '_'
    docker_container="${docker_image//\//\_}_container"
fi

# print arguments
#DEBUG="true"
if [[ "$DEBUG" = "true" ]]; then
echo ">>> Parameters:"
echo "  image_from                  : $image_from"
echo "  docker_image                : $docker_image"
echo "  docker_container            : $docker_container"
echo ""
echo "  path_mapping                : $path_mapping"
echo "  opt_auto_commit_dockerimage : $opt_auto_commit_dockerimage"
echo "  opt_auto_rm_container       : $opt_auto_rm_container"
echo "  opt_nvidia_docker2          : $opt_nvidia_docker2"
echo "  opt_command                 : $opt_command"
echo ""
fi

# do action
case $act in
    build)  build_docker_image;;
    run)    run_docker_container;;
    delete) rm_docker_container;;
    commit) commit_docker_container;;
    save)   saveImage;;
    load)   loadImage;;
esac

