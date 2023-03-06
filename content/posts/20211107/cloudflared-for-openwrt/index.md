---
title: "OpenWrtでCloudflaredを動かしてみる"
date: "2021-11-07T08:31:00Z"
tags: ["linux", "cloudflare", "openwrt"]
comments: true
showToc: true
---

ルーター上でCloudflaredを動かしてみたかったのでやってみた

## ビルド方法

[これ](https://github.com/cloudflare/cloudflared)をクローン  
`GOOS=linux GOARCH=mipsle make cloudflared`  
アーキテクチャは必要に応じて変更してください

## 動かす

バイナリが20MBくらいあるのでexrootで拡張するか、別のデバイスに置く必要があります。

デーモン化する場合は、`/etc/init.d/cloudflared`に以下のようなファイルを作成します。
```bash
!/bin/sh /etc/rc.common

START=99
STOP=15

start() {
        # commands to launch application
        export TUNNEL_PIDFILE=/tmp/cloudflared.pid
        /mnt/sda1/bin/cloudflared tunnel run --token hogehoge
}

stop() {
        # commands to kill application
        kill $(cat /tmp/cloudflared.pid)
        sleep 5
}
```
`/etc/init.d/cloudflared enable`で有効になります。