#!/bin/bash

# Wrapper that takes in a polygon lon,lat comma delimited string, and a maxCount of granules, and builds an animation from S1-GRD images.
# ./animate_poly_wrapper.sh "-155.08,65.82,-153.5,61.91,-149.50,63.07,-149.94,64.55,-153.28,64.47,-155.08,65.82" 30

polygon=$1
maxcount=$2

allowed_polarizations=("hh" "hv" "vv" "vh")
WORKDIR=$(pwd)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# pull the granules
${DIR}/pull_asf_polygon.sh "${polygon}" "${maxcount}"

# unzip and compile files into proper subdirectories
${DIR}/compile_files.sh

# for each polarization
for poldir in "${allowed_polarizations[@]}"
do
    # compress the granules and remove the uncompressed files
    ${DIR}/compress_files.sh "${poldir}" 1

    # move the files into proper subdirectories by date
    ${DIR}/group_by_time_interval.sh --folder "${poldir}" --interval 4 --regex "*.compressed.tiff"

    # merge each file in the subdirectories
    ${DIR}/merge_by_date.sh ${poldir}

    # generate the animation
    ${DIR}/generate_browse.sh
done

