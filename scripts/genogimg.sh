#!/bin/bash

STRING=$1
BASEIMG=$2
OUTIMG=$3

if !(type convert&>/dev/null); then
  echo "Please install ImageMagick"
  exit 1
fi

if [ "$#" -ne 3 ]; then
  echo "./genogimg.sh <string> <baseimage> <outputimage>"
  exit 1
fi

convert \
  -fill "#4169e1" \
  -background "#00000000" \
  -font "./font/IBMPlexSansJP-Bold.ttf" \
  -pointsize 70 \
  -gravity Center \
  -size 1100 \
  caption:"$STRING" \
  "$BASEIMG" +swap +antialias \
  -gravity Center \
  -composite \
  $OUTIMG

echo "Generated $OUTIMG"