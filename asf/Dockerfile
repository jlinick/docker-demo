# Centos static image
FROM ubuntu:groovy-20200723
MAINTAINER jlinick@mit.edu

# Set the working directory
WORKDIR /home

# Install necessary items
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y jq aria2 zip unzip curl git vim

RUN git clone https://github.com/jlinick/docker-demo.git /docker-demo

RUN echo 'alias location-of=/docker-demo/find_name.sh' >> ~/.bashrc && \
    echo 'alias query-asf=/docker-demo/query_asf.sh' >> ~/.bashrc && \
    echo 'alias pull-asf=/docker-demo/pull_asf.sh' >> ~/.bashrc && \
    echo 'alias compile-files=/docker-demo/compile.sh' >> ~/.bashrc
