# Docker environment with X11, OpenGL, ROS

1. build Docker image

make nvidia_ros_noetic

2. run Docker container

bash run.sh

3. run multiple terminals for multiple ROS nodes connected to the same container

docker exec -it --user <user_name> <container_id> bash
