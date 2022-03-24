FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu20.04

MAINTAINER yang zhao <zhao.yang@ieee.org> 
LABEL Description="ROS-Melodic-Desktop (Ubuntu 18.04)" 

ENV http_proxy=${http_proxy} \
    https_proxy=${https_proxy} \
    no_proxy=${no_proxy}  \
    DEBIAN_FRONTEND=noninteractive 

#COPY certs/*.crt /usr/local/share/ca-certificates/
RUN apt update && \
    apt-get install ca-certificates git -y && \
    update-ca-certificates 

# Install packages
RUN apt-get update && apt-get install -y \
    locales \
    lsb-release \
    mesa-utils \
    git \
    subversion \
    nano \
    vim \
    terminator \
    xterm \
    wget \
    curl \
    htop \
    libssl-dev \
    build-essential \
    dbus-x11 \
    software-properties-common \
    gdb valgrind && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
    
# Install new paramiko (solves ssh issues)
RUN apt-add-repository universe
RUN apt-get update && apt-get install -y python3-pip python3 build-essential && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN /usr/bin/yes | pip3 install --upgrade pip
RUN /usr/bin/yes | pip3 install --upgrade virtualenv
RUN /usr/bin/yes | pip3 install --upgrade paramiko
RUN /usr/bin/yes | pip3 install --ignore-installed --upgrade numpy protobuf

# Locale
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# Install OhMyZSH
RUN apt-get update && apt-get install -y zsh && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
#RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
RUN chsh -s /usr/bin/zsh root
RUN git clone https://github.com/sindresorhus/pure /root/.oh-my-zsh/custom/pure
RUN ln -s /root/.oh-my-zsh/custom/pure/pure.zsh-theme /root/.oh-my-zsh/custom/
RUN ln -s /root/.oh-my-zsh/custom/pure/async.zsh /root/.oh-my-zsh/custom/
RUN sed -i -e 's/robbyrussell/refined/g' /root/.zshrc
RUN sed -i '/plugins=(/c\plugins=(git git-flow adb pyenv tmux)' /root/.zshrc

# Terminator Config
RUN mkdir -p /root/.config/terminator/

# Install Docker
RUN apt-get update && apt -y install apt-transport-https ca-certificates curl software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
RUN apt-get update && apt-cache policy docker-ce && apt-get -y install docker-ce

## Install PX4
## https://github.com/PX4/PX4-containers/blob/master/docker/Dockerfile_base-bionic
RUN apt-get update && apt-get -y --quiet --no-install-recommends install \
    bzip2 \
    ca-certificates \
    ccache \
    cmake \
    cppcheck \
    curl \
    dirmngr \
    doxygen \
    file \
    g++ \
    gcc \
    gdb \
    git \
    gnupg \
    gosu \
    lcov \
    libfreetype6-dev \
    libgtest-dev \
    libpng-dev \
    libssl-dev \
    lsb-release \
    make \
    ninja-build \
    openjdk-8-jdk \
    openjdk-8-jre \
    openssh-client \
    pkg-config \
    python3-dev \
    python3-pip \
    rsync \
    shellcheck \
    tzdata \
    unzip \
    valgrind \
    wget \
    xsltproc \
    zip \
    && apt-get -y autoremove \
    && apt-get clean autoclean \
    && rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# Install Python 3 pip build dependencies first.
RUN pip3 install wheel setuptools

# Python 3 dependencies installed by pip
RUN pip3 install argparse argcomplete coverage cerberus empy jinja2 kconfiglib \
    matplotlib==3.0.* numpy nunavut>=1.1.0 packaging pkgconfig pyros-genmsg pyulog \
    pyyaml requests serial six toml psutil pyulog wheel jsonschema

# astyle v3.1
RUN wget -q https://downloads.sourceforge.net/project/astyle/astyle/astyle%203.1/astyle_3.1_linux.tar.gz -O /tmp/astyle.tar.gz \
    && cd /tmp && tar zxf astyle.tar.gz && cd astyle/src \
    && make -f ../build/gcc/Makefile -j$(nproc) && cp bin/astyle /usr/local/bin \
    && rm -rf /tmp/*

# SITL UDP PORTS
EXPOSE 14556/udp
EXPOSE 14557/udp
## end of PX4 install

# Install ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
#RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN curl -LJO https://github.com/ros/rosdistro/raw/master/ros.key
RUN apt-key add ros.key
RUN apt-get update && apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
libpcap-dev \
gstreamer1.0-tools libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev \
ros-noetic-desktop-full python3-rosdep python3-rosinstall-generator python3-vcstool build-essential \
ros-noetic-socketcan-bridge \
ros-noetic-geodesy && \
apt-get clean && rm -rf /var/lib/apt/lists/*


# Configure ROS
#RUN rosdep init && rosdep update
RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc
RUN echo "export ROSLAUNCH_SSH_UNKNOWN=1" >> /root/.bashrc
RUN echo "source /opt/ros/noetic/setup.zsh" >> /root/.zshrc
RUN echo "export ROSLAUNCH_SSH_UNKNOWN=1" >> /root/.zshrc

# Install packages (based on previous experience, may not be all necessary)
RUN apt-get update && apt-get install -y -qq \
iputils-ping \
build-essential

RUN apt-get update \
    && apt-get install -y \
    apt-utils \
    file \
    cmake \
    bash-completion \
    python3-software-properties \
    python3 \
    python3-pip \
    python3-dev \
    python3-tk \
    python3-venv \
    python3-numpy \
    sqlite3 \
    libproj-dev \
    libjsoncpp-dev \
    libgeos-dev \
    libproj-dev \
    libxml2-dev \
    libpq-dev \
    libnetcdf-dev \
    libpoppler-dev \
    libcurl4-gnutls-dev \
    libhdf4-alt-dev \
    libhdf5-serial-dev \
    libgeographic-dev \
    libfftw3-dev \
    libtiff5-dev \
    libgmp3-dev \
    libmpfr-dev \
    libxerces-c-dev \
    libmpfr-dev \
    libmuparser-dev \
    libboost-date-time-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libgsl-dev \
    libgeos++-dev \
    libpng-dev \
    sudo \
    xvfb \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*
  
# Install cmake 3.18.4
RUN git clone https://gitlab.kitware.com/cmake/cmake.git && \
cd cmake && git checkout tags/v3.18.4 && ./bootstrap --parallel=8 && make -j8 && make install && \
cd .. && rm -rf cmake

RUN apt-get update && apt-get install -y automake autoconf pkg-config libevent-dev libncurses5-dev bison && \
apt-get clean && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/tmux/tmux.git && \
cd tmux && git checkout tags/3.1 && ls -la && sh autogen.sh && ./configure && make -j8 && make install

# Install latest su-exec
RUN  set -ex; \
     \
     curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c; \
     \
     fetch_deps='gcc libc-dev'; \
     apt-get update; \
     apt-get install -y --no-install-recommends $fetch_deps; \
     rm -rf /var/lib/apt/lists/*; \
     gcc -Wall \
         /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec; \
     chown root:root /usr/local/bin/su-exec; \
     chmod 0755 /usr/local/bin/su-exec; \
     rm /usr/local/bin/su-exec.c

# provision script
COPY provision_container.sh /usr/local/bin/
RUN chmod 1777 /usr/local/bin/provision_container.sh

# install and setup QGC
RUN apt-get update && apt-get install -y fuse libpulse-dev
#RUN usermod -a -G dialout $USER
RUN apt-get remove modemmanager -y

# Install ROSbash to enable roscd
RUN apt-get install -y ros-noetic-rosbash

# install MAVROS
RUN apt-get install -y ros-noetic-mavros-msgs && \
    apt-get install -y ros-noetic-mavros ros-noetic-mavros-extras
RUN wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh && chmod +x ./install_geographiclib_datasets.sh && ./install_geographiclib_datasets.sh

# install rviz and other gazebo, px4 related packages
RUN apt-get update && apt-get install -y ros-noetic-gazebo-ros-pkgs ros-noetic-gazebo-ros-control
RUN apt-get update && apt-get install -y libgazebo11-dev
RUN apt-get update && apt-get autoremove -y
RUN pip3 install px4tools pymavlink rospkg
RUN apt-get install -y ros-noetic-rviz

ENTRYPOINT ["/usr/local/bin/provision_container.sh"]
CMD ["/bin/bash"]
