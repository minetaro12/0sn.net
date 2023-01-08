#!/bin/bash

srcdir=$(cd $(dirname $0); pwd)
pagefind_amd64="https://github.com/CloudCannon/pagefind/releases/download/v0.10.6/pagefind_extended-v0.10.6-x86_64-unknown-linux-musl.tar.gz"
pagefind_aarch64="https://github.com/CloudCannon/pagefind/releases/download/v0.10.6/pagefind_extended-v0.10.6-aarch64-unknown-linux-musl.tar.gz"

download() {
  if [ $(uname -m) = "x86_64" ]; then
    curl $pagefind_amd64 -LO
  elif [ $(uname -m) = "aarch64" ]; then
    curl $pagefind_aarch64 -LO
  else
    echo "This architecture is not supported"
    exit 1
  fi
  tar xf pagefind_extended-*.tar.gz
  rm pagefind_extended-*.tar.gz
}

cd $srcdir

#Generate OGImage
grep '^title: "' ./content/posts/*/*/*.md |\
  sed "s/:title: /\n/g" |\
  sed "s/\/index.md//g" |\
  sed -E "s/^.\/content\/posts\/([0-9]{8})\//\1-/g" |\
  sed 's/"//g' > postlist

mkdir -p ./static/img/ogp
cat postlist | xargs -n2 -d"\n" -P8 bash -c './genogimg.sh "$1" ./static/img/ogp.png "./static/img/ogp/$0.jpg"'

hugo --gc --minify

if [ ! -e ${srcdir}/pagefind_extended ]; then
  download
fi

./pagefind_extended --source public