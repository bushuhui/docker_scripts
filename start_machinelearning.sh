#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
CUR_DIR=$(dirname "$SCRIPT")

cd $CUR_DIR


# the source image
image_from="pytorch_dev"

# this docker's image
docker_image="machinelearning_image"
# the container's name
docker_container="machinelearning"

# path mapping for host<->docker
path_mapping="-v /home:/home -v $CUR_DIR:/data"


# build a docker image from a source image
build_docker_image()
{
    echo ">>> Build a docker image [$docker_image] from [$image_from]\n"; echo ""
    
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
    
    
    xhost +
    docker run -it -h "$docker_container" \
            --net=host --privileged \
            -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
            $path_mapping \
            --name $docker_container $image_from \
            bash

    docker commit $docker_container $docker_image
    docker rm $docker_container
}

# run the docker image
run_docker_container()
{
    echo ">>> Run a docker container [$docker_container] from [$docker_image]"; echo ""

    # check container is exist & run the container
    C=`docker ps -a | grep $docker_container`
    if [[ "$C" = "" ]]; then
        xhost +
        docker run -it -h "$docker_container" \
            --net=host --privileged \
            -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
            $path_mapping \
            --name $docker_container $docker_image \
            bash

        docker commit $docker_container $docker_image
        docker rm $docker_container
    else
        echo "Please press [Enter] to see the prompt!"
        docker start  $docker_container
        docker attach $docker_container
    fi
}

# delete a docker container
rm_docker_container()
{
    echo ">>> Delete a docker container [$docker_container]"; echo ""
    
    C=`docker ps -a | grep $docker_container`
    if [[ -n "$C" ]]; then
        docker commit $docker_container $docker_image
        docker rm $docker_container
    fi
}



print_usage()
{
cat << EOF
Usage: 
    ${0##*/} [-r] [-b] [-d] [-h]
                [-i IMAGE] [-s SOURCE IMAGE] [-c CONTAINER] 
                [-m PATH_MAPPING]

Create/Run/Delete docker container from image

  Acts:
    -r, --run           Run the container
    -b, --build         Build a docker image from given image
    -d, --delete        Delete a docker container
  
    -h, --help          Display this help and exit.

  Opts:
    -i, --image         Required. Set the name of the image.
    -s, --source        Required. Set the source image
    -c, --container     Required. Set the container name
    -m, --mapping       Required. Path mapping (host<->docker)
    
EOF
}


# parse input arguments
params="$(getopt -o rbdhi:s:c:m: -l run,build,delete,help,image:,source:,container:,mapping --name "$0" -- "$@")"
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
            shift
            ;;
        -b|--build)
            act="build"
            shift
            ;;
        -d|--delete)
            act="delete"
            shift
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
    esac
    shift
done


case $act in
    build)  build_docker_image;;
    run)    run_docker_container;;
    delete) rm_docker_container;;
esac

