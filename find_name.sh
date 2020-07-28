#!/bin/bash
#requires jq

source auth.key

#remove multiple spaces & replace with html
location=$(echo "$1" | sed 's/[ ]\+/ /g' | sed 's/ /%20/g')

result=$(curl -s "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input="$location"&inputtype=textquery&fields=geometry&key="$GOOGLE_API_KEY)

lat=$(echo $result | jq -c '.candidates[0].geometry.location.lat')
lon=$(echo $result | jq -c '.candidates[0].geometry.location.lng')

echo "$lon,$lat"

