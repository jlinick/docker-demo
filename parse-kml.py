#!/usr/bin/env python3

# parses a kml and prints the polygon lat,lon string

import re
import argparse

def main(kml_file):
    with open(kml_file, 'r') as file:
        data = file.read()
    res = re.search('<coordinates>(.+)</coordinates>', data, re.DOTALL)
    c_str = res.group(1).strip().replace(' ', ',')
    lst = c_str.split(',')
    step=3
    lst = [lst[i::step] for i in range(step)]
    lons = lst[0]
    lats = lst[1]
    coords = []
    for i in range(len(lats)):
        coords.append(lons[i])
        coords.append(lats[i])
    print(','.join(coords))

def parser():
    '''
    Construct a parser to parse arguments, returns the parser
    '''
    parse = argparse.ArgumentParser(description="prints the lon,lat polygon string")
    parse.add_argument("--file", required=True, default=None, help="path to kml file")
    return parse

if __name__ == '__main__':
    args = parser().parse_args()
    main(args.file)
