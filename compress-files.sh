#!/bin/bash

# compresses GeoTiffs in the input directory, will co-locate them with their regular geotiff

folder=$1                # the folder we are searching through
delete=$2                # will remove the original geotiff if this is set to true
file_extension=".tiff"   # file extension to replace
compressed_extension=".compressed"
# find matching files, but not the compressed files
tiff_paths=$(find $folder -name "*${file_extension}" -not -name "${compressed_extension}.${file_extension#.}" -printf '%p\n' | sort -u)
for tiff_path in ${tiff_paths}
do
    # attempt to compress each GeoTiff
    tiff_filename=$(basename "${tiff_path}")
    tiff_folder=$(dirname "${tiff_path}")
    filebase="$(echo ${tiff_filename} | sed 's/.'"${file_extension}"'//g')"  # filename without extension
    compressed_tiff_filename="${filebase}.${compressed_extension#.}.${file_extension#.}"
    compressed_tiff_path="${tiff_folder}/${compressed_tiff_filename}"
    #echo "compressed tiff filename: ${compressed_tiff_filename}"
    gdal_translate -q -r nearest \
        -co COMPRESS=ZSTD \
        -co PREDICTOR=2 \
	-co NUM_THREADS=ALL_CPUS \
	${tiff_path} ${compressed_tiff_path} 2>/dev/null

    if [ ${delete} ]; then
        rm ${tiff_path}
    fi
done

