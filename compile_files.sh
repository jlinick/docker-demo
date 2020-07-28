#!/bin/bash

allowed_polarizations=("hh" "hv" "vv" "vh")

#unzip the folders
unzip "*.zip" && rm -f *.zip

tiff_folders=$(find . -name '*.tiff' -printf '%h\n' -path './S1*' |sort -u)

# find all folders containing tiff files
for folder in ${tiff_folders}
do
    # for each folder split by polarization and place in current directory
    for pol in "${allowed_polarizations[@]}"
    do
        matching_files=$(find . -name "*${pol}*.tiff" -printf '%p\n' | sort -u)
        for file in $matching_files
	do
            if [ "$(basename $folder)" != "$pol" ]; then 
                fil=$(basename "$file")
	        mkdir -p $pol
	        cp -n $folder/$fil ./$pol/$fil 2>>/dev/null
	    fi
        done
    done
done

