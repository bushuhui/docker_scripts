#!/bin/bash

# command example: save odm_dev image
#   docker commit odm_dev_container odm_dev
#   docker save odm_dev -o odm_dev.tar

docker_container=""
docker_image=""


save_docker_container()
{
    echo ""; echo ">>> commit [$docker_container] -> [$docker_image] ..."
    docker commit "$docker_container" "$docker_image"
    
    echo ""; echo ">>> save [$docker_image] -> local file: ${docker_image}.tar ..."
    docker save "$docker_image" -o "${docker_image}.tar"
}


save_docker_image()
{
    echo ""; echo ">>> save [$docker_image] -> local file: ${docker_image}.tar ..."
    docker save "$docker_image" -o "${docker_image}.tar"
}


show_usage()
{
cat << EOF
Usage: 
    ${0##*/} [-c docker_container] [-i docker_image]

Save docker container or image to local file

  Opts:
    -i, --image         Required. Set the name of the image.
    -c, --container     Required. Set the container name
    
EOF
}


# parse input arguments
params="$(getopt -o hi:c: -l image:,container: --name "$0" -- "$@")"
eval set -- "$params"

save_container=""

while [[ $# -gt 0 ]] ; do
    case $1 in
        -h|-\?|--help)
            show_usage
            exit 0
            ;;
            
            
        -i|--image)
            if [ -n "$2" ]; then
                docker_image=$2
                
                if [[ ! -n "$docker_container" ]]; then
                    docker_container="${docker_image}_container"
                fi
                
                shift
            fi
            ;;
        -c|--container)
            if [ -n "$2" ]; then
                docker_container=$2
                
                shift
            fi
            
            save_container="true"
            ;;
    esac
    shift
done


if [[ -n "$save_container" ]]; then
    save_docker_container
else
    if [[ -n "$docker_image" ]]; then
        save_docker_image
    else
        show_usage
        exit 0
    fi
fi

