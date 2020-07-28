# Centos static image
FROM ubuntu:groovy-20200723
MAINTAINER jlinick@mit.edu

# Set the working directory
WORKDIR /home

# Install necessary items
RUN apt-get update && \
    apt-get install -y jq && \
    apt-get install -y aria2 && \
    apt-get install -y zip unzip && \
    apt-get install -y git

RUN git clone https://github.com/jlinick/docker-demo.git 
