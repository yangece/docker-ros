#!/bin/bash

set -o errexit
set +o nounset
set -o pipefail

# This is about the best we can do to provide the conatiner id of the running container
# There is a chance if you are staring containers very close together in time it will be wrong
export CONTAINER_ID=$(docker ps -ql)

# Check if any values are blank and set defaults as needed
if [ -z $USER_ID ]; then
  USER_ID=0
fi
if [ -z $USER ]; then
  USER="root"
fi
if [ -z $GROUP_ID ]; then
  GROUP_ID=0
fi
if [ -z $GROUP ]; then
  GROUP="root"
fi

if [ ! -z $DOCKER_GID ]; then
  if [ ! $(getent group $DOCKER_GID) ]; then
    # We call this group docker_host as the docker group is created by
    # the install of 
    groupmod -g $DOCKER_GID docker
  fi
fi

echo "Starting container uid=${USER_ID}(${USER}) gid=${GROUP_ID}(${GROUP})..."

if [ ! $(getent group $GROUP_ID) ]; then
  # Add if the group does not exist
  groupadd --gid $GROUP_ID $GROUP
fi


if [ ! $(getent passwd $USER_ID) ]; then
  # If this user doesn't already exist - we will setup the new user
  # and provide docker and sudo access 

  # Add the user
  home_dir=/home/$USER
  useradd --shell /bin/bash -o --uid $USER_ID --gid $GROUP_ID $USER --home $home_dir

  # Ensure the home directory exists...  It may have beem mapped in as a volume
  # so there would be no need to create or chmod
  if [ ! -d "$home_dir" ]; then
    mkdir -p $home_dir
    chown $USER_ID:$GROUP_ID $home_dir
  fi

  # Add this user to the docker group matching the host's docker gid
  # This will allow our user to run docker commands without sudo
  #usermod -aG $DOCKER_GID ${USER}

  # Allow the user no password sudo access
  echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER}
else
  # probably should check to see if the user (by uid) is in the group (by gid) and if not add
  :
fi

# configure ROS
echo "source /opt/ros/noetic/setup.bash" >> /home/${USER}/.bashrc

exec /usr/local/bin/su-exec $USER "$@"
