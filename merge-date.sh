#!/bin/bash

set -x
# merges files by subdir under the input directory

DIR=$1
for subdir in $(find ${DIR} -maxdepth 1 -name '[0-9]*' -type d); do
    if [ -d "${subdir}" ]; then
        # merge all the compressed files
        subdir=$(basename ${subdir})
        files=$(find "${DIR}/${subdir}" -name "*.compressed.tiff" -printf '%p ' | sort -u)
	merged_file="${DIR}/${subdir}.merged.tiff"
	final_file="${DIR}/${subdir}.merged.masked.tiff"
	if [ ! -f "${final_file}" ]; then
	    for file in $files; do
	        filename="$(basename "${file}")"    # full filename without the path
	        filebase="$(echo ${filename} | sed 's/.compressed.tiff//g')"  # filename without extension
	        warped_file=${filebase}.warped.tiff
                # project the compressed geotiff
		#gdalwarp -of GTiff -refine_gcps 10 -order 3 -s_srs EPSG:4326 -novshiftgrid -srcnodata 0 \
			#-t_srs '+proj=laea +lon_0=-68.5656738 +lat_0=-90 +datum=WGS84 +units=m +no_defs' \
			#-r near -dstalpha -multi -of GTiff ${file} ${DIR}/${subdir}/${warped_file}
	        gdalwarp -of GTiff -refine_gcps 10 -order 3 -s_srs "EPSG:4326" -t_srs "EPSG:3031" \
                        -wo "NUM_THREADS=ALL_CPUS" -multi -r near \
			-of GTiff ${file} ${DIR}/${subdir}/${warped_file}

                
                # convert and scale
		gdal_translate -of GTiff -scale 100 6000 0 255 -ot Byte \
			${DIR}/${subdir}/${warped_file} ${DIR}/${subdir}/${filebase}.translate.tiff
	        # strip black edges
		nearblack -of VRT -nb 1 -near 0 -setalpha ${DIR}/${subdir}/${filebase}.translate.tiff
            done
            # merge multiple files into mosaic
            gdal_merge.py -ot Byte -of GTiff -n 0 -o ${merged_file} ${DIR}/${subdir}/*.translate.tiff
            # set band 2 as alpha
            gdal_translate ${DIR}/${subdir}.merged.tiff ${final_file} -b 1 -mask 2 -co COMPRESS=LZW --config GDAL_TIFF_INTERNAL_MASK YES
            #burn the grounding line as 255
	    gdal_rasterize -burn 255 ${DIR}/clippedg.shp ${final_file} # temporary shapefile

	    # clean up 
            #rm -rf ${DIR}/${subdir}
            rm ${DIR}/${subdir}.merged.tiff
            rm ${DIR}/${subdir}/*.translate.tiff
            rm ${DIR}/${subdir}/*.warped.tiff
	fi
    fi
done

