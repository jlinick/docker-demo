FROM osgeo/gdal:latest
MAINTAINER jlinick@mit.edu

# Set the working directory
WORKDIR /home

# Install necessary items
RUN apt-get update && \
    apt-get install -y zip unzip && \
    apt-get install -y git

# Install pip for python2
RUN apt-get install -y software-properties-common && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y python3-distutils && \
    curl -s https://bootstrap.pypa.io/get-pip.py --output get-pip.py && \
    python3 get-pip.py

# clone current repo
RUN git clone https://github.com/jlinick/docker-demo.git

#clone and build iceutils repo and requirements
RUN git clone https://github.com/bryanvriel/iceutils.git
RUN pip install numpy scipy matplotlib h5py pyproj scikit-learn scikit-image tqdm pint pymp-pypi pint cvxopt
RUN python /home/iceutils/setup.py install
