#!/bin/bash

srcdir=$(cd $(dirname $0); pwd)
cd ${srcdir}/../

# ./publicがあれば削除
if [ -d ./public ]; then
  rm -rf ./public
fi

# ビルド
git fetch --unshallow

# 最新のコミットハッシュを取得
export HUGO_GITHASH=$(git rev-parse --short HEAD)

hugo --gc --minify
