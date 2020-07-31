# Docker demo
> Simple Docker demo for querying, retrieving, & processing SAR data based on a text string input.

 ### Quick demo
 
 1. Clone the repo & fill auth.key.example with keys for Earthdata login Google Maps API.
 ```shell
$ git clone https://github.com/jlinick/docker-demo
$ cd docker-demo
$ mv auth.key.example auth.key
$ nano auth.key
```
 2. build your containers
 ```shell
 $ docker build -t asf:demo asf && docker build -t gdal:demo gdal
 ```
  
  3. choose any location string (here it is Thwaites Glacier) and run the following command:
  ```shell
  $ docker run -v $(pwd):/home asf:demo /bin/bash -c '/docker-demo/pull-asf.sh $(/docker-demo/location-of.sh "Thwaites Glacier") && /docker-demo/compile-files.sh' && docker run -v $(pwd):/home gdal:demo /docker-demo/generate-browse.sh
  ```
  
  
### Walkthrough

#### Build the images

Clone the repo locally
```shell
$ git clone https://github.com/jlinick/docker-demo
```
  
cd into the cloned dir
```shell
$ cd docker-demo
```
  
build the docker asf image
```shell
$ docker build -t asf:demo asf
```
  
build the docker gdal image
```shell
$ docker build -t gdal:demo gdal
```

##### Run the ASF image to query & retrieve your data

Now run the ASF image and jump into the container
```shell
$ docker run -ti -v $(pwd):/home asf:demo
```

get the location of your string, put whatever location you like
```shell
$ location-of "Thwaites Glacier"
-108.5000001,-74
```

take the result and put it into your ASF query to see if there are any GRD files over the location
```shell
$ query-asf "-108.5000001,-74"
462
```

Now download granule from ASF over your location
```shell
$ pull-asf "-108.5000001,-74"
```

Extract the zip to a folder (by polarization)
```shell
$ compile-files
```

now exit your container
```shell
$ exit
```

##### Run the GDAL image to project your file and generate browse & kml files

```shell
$ docker run -ti -v $(pwd):/home gdal:demo
$ generate-browse
$ exit
```

and you're done!
