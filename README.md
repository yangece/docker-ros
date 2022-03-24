# Docker Containters with X11 and ROS, PX4 Dev Support

This repo provides an example and tutorial to build and run a Docker container with X11 support for ROS and PX4 related software development.

## Build Docker image

- build Docker image
A simple Makefile is provided for building the Docker image. Simply run the following command to build the image:

```
make nvidia_ros_noetic
```

## Run Docker container

- run Docker container
A corresponding run.sh script is provided for running the Docker container:

```
bash run.sh
```

- run multiple terminals for multiple ROS nodes connected to the same container

```
docker exec -it --user <user_name> <container_id> bash
```

## Reference

- https://github.com/turlucode/ros-docker-gui
- https://docs.px4.io/master/en/ros/
