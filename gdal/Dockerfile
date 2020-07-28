FROM osgeo/gdal:latest
MAINTAINER jlinick@mit.edu

# Set the working directory
WORKDIR /home

# Install necessary items
RUN apt-get update && \
    apt-get install -y zip unzip git vim

# clone current repo
RUN git clone https://github.com/jlinick/docker-demo.git /docker-demo

RUN echo 'alias generate-browse=/docker-demo/generate_browse.sh' >> ~/.bashrc
