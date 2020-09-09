#!/bin/bash

# merges files by subdir under the input directory

DIR=$1
for subdir in $(find $DIR -maxdepth 1 ! -name '.*' -type d); do
    if [ -d "${subdir}" ]; then
       # merge all the compressed files
       files=$(find "${subdir}" -name "*.compressed.tiff" -printf '%p ' | sort -u)
       gdal_merge.py -of GTiff  -o "${subdir}.merged.tiff" ${files}
    fi
done

