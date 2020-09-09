#!/bin/bash

# merges files by subdir under the input directory

DIR=$1
for subdir in ${DIR}; do
    if [ -d "$f" ]; then
       # merge all the compressed files
       gdal_merge.py -of GTiff  -o "${DIR}/${subdir}.merged.tiff" "${DIR}/*.compressed.tiff"
    fi
done

