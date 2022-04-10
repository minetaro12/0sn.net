#!/bin/sh

for FILE in ./content/posts/*/*/*.md
do
  FULLDIR=$(dirname $FILE)
  DIRNAME=$(basename $FULLDIR)
  DATE=$(basename `dirname $FULLDIR`)
  ./bin/tcardgen \
    -f ./font \
    -o ./static/ogp/$DATE-$DIRNAME.png \
    -t ./ogp.png \
    -c ./tcardgen.yml \
    $FILE
done

TZ='Asia/Tokyo' hugo --gc --minify
