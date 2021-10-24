#!/bin/bash

# Grab the current user's uid and gid information
USER_ID=$(id -u)
GROUP_ID=$(id -g)
GROUP=$(id -ng)
DOCKER_GID=$(cut -d: -f3 < <(getent group docker))
CNAME=${USER}_$(date +%m%d_%H%m%S)

# add mount points
mounts=""
if [ -d "/home" ]; then
	mounts="$mounts -v /home;/home"
fi

docker run --rm -it \
	--runtime=nvidia \
	--privileged --net=host --ipc=host \
	--name=$CNAME \
	-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY \
	-v $HOME/.Xauthority:/home/$(id -un)/.Xauthority \
	-v $HOME:$HOME \
	$mounts \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--workdir=$(pwd) \
	-e XAUTHORITY=/home/$(id -un)/.Xauthority \
	-e DOCKER_USER_NAME=$(id -un) \
	-e DOCKER_USER_ID=$(id -u) \
	-e DOCKER_USER_GROUP_NAME=$(id -gn) \
	-e DOCKER_USER_GROUP_ID=$(id -g) \
	-e ROS_IP=127.0.0.1 \
	-e USER=$USER \
        -e USER_ID=$USER_ID \
        -e GROUP=$GROUP \
        -e GROUP_ID=$GROUP_ID \
        -e DOCKER_GID=$DOCKER_GID \
	yz/ros-noetic:latest \
	"$@"
