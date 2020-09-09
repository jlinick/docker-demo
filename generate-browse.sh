#!/bin/bash

#set -x
#set -e

# Uses GDAL to generate brrowse imagery for tiff images in the workdir under vv,vh,hv, or hh subdirectories
projections=("3995", "3031") # first is arctic, second is antarctic
use_projection="${projections[1]}" # which projection to use, will set this to be an input (to project based on loc properly)
allowed_polarizations=("hh" "hv" "vv" "vh")
num_procs=32 # number of parallel processes to run concurrently

function get_size () {
    file_path="${1}"
    awk 'Size is{print}' | gdalinfo ${file_path}
}

gdal_time() {
    if [[ -z "$1" ]]; then
        echo "Missing arguments. Syntax:"
        echo "  gdal_pixelsize_gdalwarp_tr <input_raster>"
        return
    fi;
    DATETIME=$(gdalinfo "$1" |\
        grep "TIFFTAG_DATETIME=" |\
	sed "s/TIFFTAG_DATETIME=//g" |\
	    tr -cd '0-9' );
	#tr -c " " "T" |\
        #tr -d "[(,])-");
    echo -n "$DATETIME"
}

for folder in ${allowed_polarizations[*]}; do
    if [[ -d "${folder}" ]] ; then
        matching_files=$(find $folder -name "*${folder}*.merged.tiff" -printf '%p\n' | sort -u)
        for file in $matching_files
        do
	    # filenames & paths
            filename="$(basename "${file}")"                   # full filename without the path
            filebase="$(echo ${filename} | sed 's/.merged.tiff//g')"  # filename without extension
            datetime=$(gdal_time ${file})
	    proj_ext="projected.vrt"                           # extension for the projected file (file type needs to match GDAL -of)
	    projected="${folder}/${datetime}.${proj_ext}"      # projected file path
            mpeg_ext="mpeg.png"                                # extension for smaller vrt used for animation
	    #counter=$(printf %03d $iterator)
	    #mpeg="${folder}/${counter}.${mpeg_ext}"           # file path to mpeg vrt
            small_ext="small.vrt"                             # extension for smaller geotiff
	    small_tif="${folder}/${datetime}.${small_ext}"       # smaller version of image
	    browse_file_type="png"                             # file type of browse image
	    browse="${folder}/${filebase}.${browse_file_type}" # browse file path
            kml_folder="${folder}/${filebase}"                 # kml folder path
	    kmz_filename="${filebase}.kmz"                     # kmz filename
            
            # project using Arctic or Antarctic projection EPSG to a VRT
            gdalwarp -overwrite -t_srs "EPSG:${use_projection}" -co PHOTOMETRIC=MINISBLACK -of VRT -ot Byte "${folder}/${filename}" "${projected}" 2>/dev/null
            
            gdal_translate -outsize 4096 0 -ot Byte -of VRT "${projected}" "${small_tif}"

            # take the projection and save it as a browse png
	    gdal_translate -outsize 10% 10% -ot Byte "${projected}" "${browse}"

            # generate a tiled kmz. first generate a kml, then zip it into a kmz and remove the kml folder
	    #/usr/bin/gdal2tiles.py -k --srcnodata=0 --processes "${num_procs}" -z 3-10 "${projected}" "${kml_folder}"
	    #cd "${kml_folder}" && zip -r "../${kmz_filename}" * && cd ../..
	    #rm -rf "${kml_folder}"
	    #rm -f "$projected_tiff"
        done
        # if there are multiple browse files, we will generate an animated file
	browse_count=$(find $folder -maxdepth 1 -name "*.${small_ext}" -printf '%p\n' | sort -u | wc -l)
	if [ "${browse_count}" -gt "1" ] ; then

	    echo "generating animation using ${browse_count} frames..."
            # generate merged shapefile
            gdaltindex -src_srs_format EPSG -src_srs_name src_srs -t_srs "EPSG:${use_projection}" "${folder}/extent.shp" "${folder}"/*."${proj_ext}"

	    # cut all images to the shapefile
            iterator=1
	    matching_files=$(find $folder -name "*.${small_ext}" -printf '%p\n' | sort -u)
	    for file in $matching_files
            do
		filename="$(basename "${file}")"                   # full filename without the path
	        filebase="$(echo ${filename} | sed 's/.'"${small_ext}"'//g')"  # filename without extension
		counter=$(printf %03d $iterator)
		warp="${folder}/${filebase}.${counter}.warped.vrt"
		mpg="${folder}/${counter}.mpg.png"

                # crop to the shapefile extent
		gdalwarp -overwrite -cutline "${folder}/extent.shp" -crop_to_cutline -dstalpha "${file}" "${warp}"
		# export as png
                gdal_translate -outsize 4096 0 -of PNG -r nearest "${warp}" "${mpg}" # THIS IS EXTREMELY SLOW. NEED TO MAKE FASTER
		iterator=$((iterator+1))
            done
            ffmpeg -r 10 -i "${folder}/%03d.mpg.png" "${folder}/animation.gif"
            rm "${folder}"/*.vrt
	    rm "${folder}"/*.xml
	    rm "${folder}"/*."${small_ext}"
	    rm "${folder}"/*.mpg.png
	fi
    fi
done

