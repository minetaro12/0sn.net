#!/bin/bash

srcdir=$(cd $(dirname $0); pwd)
pagefind_amd64="https://github.com/CloudCannon/pagefind/releases/download/v0.12.0/pagefind_extended-v0.12.0-x86_64-unknown-linux-musl.tar.gz"
pagefind_aarch64="https://github.com/CloudCannon/pagefind/releases/download/v0.12.0/pagefind_extended-v0.12.0-aarch64-unknown-linux-musl.tar.gz"

download() {
  if [ $(uname -m) = "x86_64" ]; then
    curl ${pagefind_amd64} -L | tar xzvf -
  elif [ $(uname -m) = "aarch64" ]; then
    curl ${pagefind_aarch64} -L | tar xzvf -
  else
    echo "This architecture is not supported"
    exit 1
  fi
}

# if !(type convert&>/dev/null); then
#   echo "Please install ImageMagick"
#   exit 1
# fi

# #Generate OGImage
# mkdir -p ./static/img/ogp
# grep '^title: "' ./content/posts/*/*/*.md |\
#   sed "s/:title: /\n/g" |\
#   sed "s/\/index.md//g" |\
#   sed -E "s/^.\/content\/posts\/([0-9]{8})\//\1-/g" |\
#   sed 's/"//g' |\
#   xargs -n2 -d"\n" -P8 bash -c './genogimg.sh "$1" ./static/img/ogp.png "./static/img/ogp/$0.jpg"'

cd ${srcdir}/../

hugo --gc --minify

if [ ! -e ./pagefind_extended ]; then
  download
fi

./pagefind_extended --source public

# Purge Cache
json=$(cat << EOS
{
  "files": [
    "https://0sn.net/js/script.min.js",
    "https://0sn.net/css/style.min.css"
  ]
}
EOS
)

curl https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/purge_cache \
  -X POST \
  --header "Authorization: Bearer ${CF_API_KEY}" \
  --header "Content-Type: application/json" \
  --data "${json}"