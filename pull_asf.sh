#!/bin/bash

source auth.key

# requires aria2 for the downloading

# read from pipe or input
if (( ${#} == 0 )) ; then
    while read -r line ; do
        input="${line}"
    done
else
    input="${1}"
fi
# fix url encoding for the comma
location=$(echo "$input" | sed 's/[,]\+/+/g')

query="https://api.daac.asf.alaska.edu/services/search/param?platform=S1&processingLevel=GRD_HS,GRD_HD&start=2+weeks+ago&end=now&maxResults=10&intersectsWith=point%28"$location"%29&output=metalink"

aria2c --http-auth-challenge=true --http-user="$EARTHDATA_USER" --http-passwd="$EARTHDATA_PASSWORD" "$query"
unzip "*.zip"

