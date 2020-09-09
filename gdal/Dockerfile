FROM osgeo/gdal:latest
MAINTAINER jlinick@mit.edu

# Set the working directory
WORKDIR /home

MAINTAINER jlinick@mit.edu

# Set the working directory
WORKDIR /home

# Install necessary items
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y jq aria2 zip unzip curl git vim ffmpeg

# Install pip
RUN apt-get install -y software-properties-common && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y python3-distutils && \
    curl -s https://bootstrap.pypa.io/get-pip.py --output get-pip.py && \
    python3 get-pip.py && \
    rm -rf get-pip.py

RUN echo 'alias location-of=/docker-demo/location-of.sh' >> ~/.bashrc && \
    echo 'alias query-asf=/docker-demo/query-asf.sh' >> ~/.bashrc && \
    echo 'alias pull-asf=/docker-demo/pull-asf.sh' >> ~/.bashrc && \
    echo 'alias compile-files=/docker-demo/compile-files.sh' >> ~/.bashrc && \
    echo 'alias generate-browse=/docker-demo/generate-browse.sh' >> ~/.bashrc

# clone current repo
RUN git clone https://github.com/jlinick/docker-demo.git /docker-demo


