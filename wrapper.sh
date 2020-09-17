#!/bin/bash

# Wrapper that takes in a polygon lon,lat comma delimited string, and a maxCount of granules, and builds an animation from S1-GRD images.
# ./animate_poly_wrapper.sh test.kml 30

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# get the kml into a polygon string
kml_path=$1
polygon=$($DIR/parse-kml.py --file ${kml_path})
maxcount=$2

allowed_polarizations=("hh" "hv" "vv" "vh")
WORKDIR=$(pwd)

# pull the granules
#${DIR}/pull-asf-polygon.sh "${polygon}" "${maxcount}"

# unzip and compile files into proper subdirectories
#${DIR}/compile-files.sh

# for each polarization
for poldir in "${allowed_polarizations[@]}"
do
    if [[ -d ${poldir} ]]; then
        # compress the granules and remove the uncompressed files
        #${DIR}/compress-files.sh "${poldir}" 1

        # move the files into proper subdirectories by date
        #${DIR}/group-by-time-interval.py --folder "${poldir}" --interval 4 --regex "*.compressed.tiff"

        # merge each file in the subdirectories
	#${DIR}/merge-date.sh ${poldir}

        # generate the animation
        ${DIR}/generate-animation.sh ${kml_path}
    fi
done

