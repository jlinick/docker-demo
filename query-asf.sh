#!/bin/bash

source auth.key
# read from pipe or input
if (( ${#} == 0 )) ; then
    while read -r line ; do
        input="${line}"
    done
else
    input="${1}"
fi

#fix url encoding for the comma
location=$(echo "$input" | sed 's/[,]\+/+/g')

result=$(curl -s "https://api.daac.asf.alaska.edu/services/search/param?platform=S1&processingLevel=GRD_MS,GRD_MD&intersectsWith=point%28"$location"%29&output=count")
echo $result

