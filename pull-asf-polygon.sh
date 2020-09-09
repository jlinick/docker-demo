#!/bin/bash

source auth.key
# Pulls GRD data from ASF. First arg is location, second optional arg is maxResults, If it's not included, defaults to 1

# requires aria2 for the downloading

# read from pipe or input
if (( ${#} == 0 )) ; then 
	args=$@
        [[ -p /dev/stdin ]] && { mapfile -t; set -- "${MAPFILE[@]}"; set -- $@ $args; }
        echo $@
else
    input="${1}"
fi
# fix url encoding for the comma
location=${input}

echo "location: ${location}"


# set maxResults
results="${2}"
if [ -z "${results}" ]
then
    results="1"
fi

query="https://api.daac.asf.alaska.edu/services/search/param?platform=S1&processingLevel=GRD_MS,GRD_MD&maxResults="${results}"&polygon="${location}"&output=metalink"

aria2c --http-auth-challenge=true --http-user="$EARTHDATA_USER" --http-passwd="$EARTHDATA_PASSWORD" "$query"

rm -f asf-datapool-results*

