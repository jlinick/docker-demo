#!/bin/bash

# Uses GDAL to generate brrowse imagery for tiff images in the workdir under vv,vh,hv, or hh subdirectories

allowed_polarizations=("hh" "hv" "vv" "vh")
for folder in ${allowed_polarizations[*]}; do
    if [[ -d "${folder}" ]]
    then
        matching_files=$(find $folder -name "*$pol*.tiff" -printf '%p\n' | sort -u)
        for file in $matching_files
        do
            filename=$(basename "$file")
            filebase=$(echo $filename | sed 's/.tiff//g')
	    projected_tiff=$folder/$filebase.projected.tiff
            # project to Geotiff, generate browse, and then kml
            gdalwarp -t_srs EPSG:4326 -co COMPRESS=JPEG -co PHOTOMETRIC=MINISBLACK -ot Byte "$folder/$filename" "$projected_tiff"
            gdal_translate -ot Byte "$projected_tiff" "$folder/$filebase.jpg"
            /usr/bin/gdal2tiles.py -k --srcnodata=0 --processes 16 -z 2-10 "$projected_tiff" "$folder/$filebase"
	    rm -f "$projected_tiff"
        done
    fi
done
