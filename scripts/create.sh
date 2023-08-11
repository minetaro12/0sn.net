#!/bin/bash

if [ "$1" = "" ]; then
  echo "名前を指定してください"
  exit 1
fi

hugo new "posts/$(date +%Y%m%d)/$1/index.md"