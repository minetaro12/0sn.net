#!/bin/sh

for FILE in ./content/posts/*/*/*.md
do
  DIRNAME=$(echo $FILE | rev | cut -d "/" -f 2 | rev)
  DATE=$(echo $FILE | rev | cut -d "/" -f 3 | rev)
  ./bin/tcardgen \
    -f ./font \
    -o ./static/ogp/$DATE-$DIRNAME.png \
    -t ./ogp.png \
    -c ./tcardgen.yml \
    $FILE
done

TZ='Asia/Tokyo' hugo --gc --minify
