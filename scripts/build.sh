#!/bin/bash

srcdir=$(cd $(dirname $0); pwd)
# pagefind_ver="v1.0.3"
# pagefind_amd64="https://github.com/CloudCannon/pagefind/releases/download/${pagefind_ver}/pagefind_extended-${pagefind_ver}-x86_64-unknown-linux-musl.tar.gz"
# pagefind_aarch64="https://github.com/CloudCannon/pagefind/releases/download/${pagefind_ver}/pagefind_extended-${pagefind_ver}-aarch64-unknown-linux-musl.tar.gz"

# download() {
#   if [ $(uname -m) = "x86_64" ]; then
#     curl ${pagefind_amd64} -L | tar xzvf -
#   elif [ $(uname -m) = "aarch64" ]; then
#     curl ${pagefind_aarch64} -L | tar xzvf -
#   else
#     echo "This architecture is not supported"
#     exit 1
#   fi
# }

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
# ビルド
hugo --gc --minify

# pagefind
# if [ ! -e ./pagefind_extended ]; then
#   download
# fi
# ./pagefind_extended --site public

# Purge Cache
# PURGE_CACHEがtrueの場合は実行、falseの場合は実行しない
if [ "${PURGE_CACHE}" = "true" ]; then
  json=$(cat << EOS
{
  "files": [
    "https://0sn.net/js/base/index.min.js",
    "https://0sn.net/js/single/index.min.js",
    "https://0sn.net/js/tags/index.min.js",
    "https://0sn.net/js/search/index.min.js",
    "https://0sn.net/index.json",
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
else
  echo "Skip purge cache"
fi
