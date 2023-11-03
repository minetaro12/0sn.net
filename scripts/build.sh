#!/bin/bash

srcdir=$(cd $(dirname $0); pwd)
cd ${srcdir}/../

# ./publicがあれば削除
if [ -d ./public ]; then
  rm -rf ./public
fi

# ビルド
hugo --gc --minify