#!/bin/bash

set -x
set -e

# Uses GDAL to generate brrowse imagery for tiff images in the workdir under vv,vh,hv, or hh subdirectories
projections=("3995", "3031") # first is arctic, second is antarctic
use_projection="${projections[1]}" # which projection to use, will set this to be an input (to project based on loc properly)
allowed_polarizations=("hh" "hv" "vv" "vh")
num_procs=32 # number of parallel processes to run concurrently

function get_size () {
    file_path="${1}"
    awk 'Size is{print}' | gdalinfo ${file_path}
}

for folder in ${allowed_polarizations[*]}; do
    if [[ -d "${folder}" ]] ; then
        matching_files=$(find $folder -name "*${folder}*.tiff" -printf '%p\n' | sort -u)
        for file in $matching_files
        do
	    # filenames & paths
            filename="$(basename "${file}")"                   # full filename without the path
            filebase="$(echo ${filename} | sed 's/.tiff//g')"  # filename without extension
	    proj_ext="projected.vrt"                           # extension for the projected file (file type needs to match GDAL -of)
	    projected="${folder}/${filebase}.${proj_ext}"      # projected file path
	    browse_file_type="png"                             # file type of browse image
	    browse="${folder}/${filebase}.${browse_file_type}" # browse file path
            kml_folder="${folder}/${filebase}"                 # kml folder path
	    kmz_filename="${filebase}.kmz"                     # kmz filename
            
            # project using Arctic or Antarctic projection EPSG to a VRT
            gdalwarp -overwrite -t_srs "EPSG:${use_projection}" -co PHOTOMETRIC=MINISBLACK -of VRT -ot Byte "${folder}/${filename}" "${projected}" 2>/dev/null
            
            # take the projection and save it as a browse png
	    gdal_translate -outsize 10% 10% -ot Byte "${projected}" "${browse}"

	    # generate a tiled kmz. first generate a kml, then zip it into a kmz and remove the kml folder
	    /usr/bin/gdal2tiles.py -k --srcnodata=0 --processes "${num_procs}" -z 3-10 "${projected}" "${kml_folder}"
	    cd "${kml_folder}" && zip -r "../${kmz_filename}" * && cd ../..
	    rm -rf "${kml_folder}"
	    #rm -f "$projected_tiff"
        done
        # if there are multiple browse files, we will generate an animated file
	browse_count=$(find $folder -maxdepth 1 -name "*.${browse_file_type}" -printf '%p\n' | sort -u | wc -l)
	if [ "${browse_count}" -gt "1" ] ; then

	    echo "generating animation using ${browse_count} frames..."
            # take the put the tiffs on a common frame
	    #gdal_merge.py -o "${folder}/merged.vrt" -of VRT -tap -separate $(ls ${folder}/*projected.vrt | paste -sd " " -)
	    
	    # generate a mosaic VRT in order to determine the minimum extent
	    #gdal_merge.py -o "${folder}/minimum_extent.vrt" -of VRT -tap $(find "${folder}" -name "*.projected.vrt" -type f | paste -sd " " -)
	    #find "${folder}" -name "*.projected.vrt" -type f > "${folder}/vrt_list.txt"
	    #gdalbuildvrt "${folder}/minimum_extent.vrt" -overwrite -input_file_list "${folder}/vrt_list.txt"
            #create polygon extent
	    #poly="${folder}/extent.json"
	    #gdal_polygonize.py "${folder}/minimum_extent.vrt" -f "GeoJSON" "${poly}"
            
            #gdal_translate -sds -of GTiff -outsize 10% 10% "${folder}/merged.vrt" "${folder}/merged.projected.tiff"
            ###gdalsrsinfo -o wkt "${folder}/minimum_extent.vrt" > "${folder}/minimum_extent.wkt"
	    #matching_vrt_files=$(find $folder -name "*${folder}*.projected.vrt" -printf '%p\n' | sort -u)
            #for vrt in $matching_vrt_files
            #do 
            #    filebase=$(echo $vrt | sed 's/.projected.vrt//g')
	    #    # echo ${filebase}
            #    output_vrt="${filebase}.projected.merged.vrt"
            #    output_png="${filebase}.projected.merged.png"
            #    #gdalwarp -of VRT -t_srs "${folder}/minimum_extent.wkt" "${vrt}" "${output_vrt}"
            #    gdalwarp -te -crop_to_cutline "${poly}" "${vrt}" "${output_vrt}"
	    #    gdal_translate -outsize 10% 10% "${output_vrt}" "${output_png}"
            #done
            
            #gtiff2mp4.sh hh/out.mp4 $(find "${folder}" -name "*.${proj_ext}" -type f | paste -sd " " -)
            # combine all of the browse into a mpeg
	    #mpeg_path="${folder}/animation.mpg"
	    #ffmpeg -r 15 -i *.png -vf scale=3200:-2 "${mpeg_path}"
	fi
    fi
done

