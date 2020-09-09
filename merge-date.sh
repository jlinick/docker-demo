#!/bin/bash

set -x
# merges files by subdir under the input directory

DIR=$1
for subdir in $(find ${DIR} -maxdepth 1 -name '[0-9]*' -type d); do
    if [ -d "${subdir}" ]; then
       # merge all the compressed files
       subdir=$(basename ${subdir})
       files=$(find "${DIR}/${subdir}" -name "*.compressed.tiff" -printf '%p ' | sort -u)
       for file in $files
       do
	   filename="$(basename "${file}")"    # full filename without the path
	   filebase="$(echo ${filename} | sed 's/.compressed.tiff//g')"  # filename without extension
	   warped_file=${filebase}.warped.tiff
           gdalwarp -of GTiff -srcnodata 0 -t_srs EPSG:3031 ${file} ${DIR}/${subdir}/${warped_file}
       done

       gdal_merge.py -of GTiff -o ${DIR}/${subdir}.merged.tiff ${DIR}/${subdir}/*.warped.tiff
       rm -rf ${DIR}/${subdir}
       gdal_translate -of GTiff -scale 200 3000 -ot Byte ${DIR}/${subdir}.merged.tiff ${DIR}/${subdir}.scaled.tiff
       rm ${DIR}/${subdir}.merged.tiff
       #gdal_translate -of PNG ${DIR}/${subdir}.scaled.tiff ${DIR}/${subdir}.png
       #gdalwarp -of GTiff -t_srs EPSG:3031 ${DIR}/${subdir}.scaled.tiff ${DIR}/${subdir}.warped.tiff
    fi
done

