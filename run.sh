#!/bin/bash
set -x

# \/ be aware of this \/
xhost +

USER_UID=$(id -u)
USER_HOME=$HOME
TAG=justinhop/synfig:latest

AARG=""

docker run -it --rm \
    --runtime=nvidia \
    --gpus=all \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    --volume=$USER_HOME/.config/synfig:$USER_HOME/.config/synfig \
    --volume=/run/user/${USER_UID}/pulse:/run/user/${USER_UID}/pulse \
    --volume=/tmp/.X11-unix:/tmp/.X11-unix:rw \
    -e DISPLAY=$DISPLAY \
    $TAG "$@"
