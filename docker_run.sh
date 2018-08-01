#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
CUR_DIR=$(dirname "$SCRIPT")


###############################################################################
# Default settings
###############################################################################
if [[ ! -n "$included" ]]; then
    # the source image
    image_from="ubuntu"

    # this docker's image
    docker_image="ubuntu_dev"
    # the container's name
    docker_container=""

    # path mapping for host<->docker
    path_mapping="-v /home:/home -v $CUR_DIR:/data"


    # commit docker container to image
    opt_commit_dockerimage="true"
    # auto remove docker container
    opt_auto_rm_container="true"
fi

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
    
    # run the docker from given source image
    xhost +
    docker run -it -h "$docker_image" \
            --net=host --privileged \
            -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
            $path_mapping \
            --name $docker_container $image_from \
            bash

    docker commit $docker_container $docker_image
    
    # auto rm docker container
    if [[ "$opt_auto_rm_container" = "true" ]]; then
        docker rm $docker_container
    fi
}

# run the docker image
run_docker_container()
{
    echo ">>> Run a docker container [$docker_container] from [$docker_image]"; echo ""

    # check container is exist & run the container
    C=`docker ps -a | grep $docker_container`
    if [[ "$C" = "" ]]; then
        xhost +
        docker run -it -h "$docker_image" \
            --net=host --privileged \
            -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
            $path_mapping \
            --name $docker_container $docker_image \
            bash

        # commit docker container to image
        if [[ "$opt_commit_dockerimage" = "true" ]]; then
            docker commit $docker_container $docker_image
        fi
        
        # auto rm docker container
        if [[ "$opt_auto_rm_container" = "true" ]]; then
            docker rm $docker_container
        fi
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
        # commit docker container to image
        if [[ "$opt_commit_dockerimage" = "true" ]]; then
            docker commit $docker_container $docker_image
        fi
        
        # remove given continer
        docker rm $docker_container
    fi
}



###############################################################################
###############################################################################

print_usage()
{
cat << EOF
Usage: 
    ${0##*/} 
        [-r] [-b] [-d] [-h]
        [-i IMAGE] [-s SOURCE IMAGE] [-c CONTAINER] 
        [-m PATH_MAPPING]
        [--commit true/false] 
        [--auto_rm_container true/false]

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
    --commit            Commit docker container to image (Default: true)
    --auto_rm_container Auto remove docker container (Default: true)
    
EOF
}


# parse input arguments
params="$(getopt -o rbdhi:s:c:m: -l run,build,delete,help,image:,source:,container:,mapping:,commit:,auto_rm_container: --name "$0" -- "$@")"
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
        --commit)
            if [ -n "$2" ]; then
                opt_commit_dockerimage=$2
                shift
            fi            
            shift
            ;;
        --auto_rm_container)
            if [ -n "$2" ]; then
                opt_auto_rm_container=$2
                shift
            fi            
            shift
            ;;
    esac
    shift
done

# set default docker container name
if [[ ! -n "$docker_container" ]]; then
    docker_container="${docker_image}_container"
fi

if [[ -n "$DEBUG" ]]; then
echo ">>> Parameters:"
echo "  image_from              : $image_from"
echo "  docker_image            : $docker_image"
echo "  docker_container        : $docker_container"
echo ""
echo "  path_mapping            : $path_mapping"
echo "  opt_commit_dockerimage  : $opt_commit_dockerimage"
echo "  opt_auto_rm_container   : $opt_auto_rm_container"
echo ""
fi

# do action
case $act in
    build)  build_docker_image;;
    run)    run_docker_container;;
    delete) rm_docker_container;;
esac
