---
title: "OpenWrtでCloudflaredを動かしてみる"
date: "2021-11-07T08:31:00Z"
tags: ["linux", "cloudflare", "openwrt"]
comments: true
showToc: true
---

ルーター上のOpenWrtでCloudflaredを動かしてみたかったのでやってみた

## ビルド方法

[これ](https://github.com/cloudflare/cloudflared)をクローン  
`GOOS=linux GOARCH=mipsle make cloudflared`  
アーキテクチャは必要に応じて変更してください

## 動かす

バイナリが20MBくらいあるのでexrootで拡張するか、別のデバイスに置く必要があります。

デーモン化する場合は、`/etc/init.d/cloudflared`に以下のようなファイルを作成します。  
ここではtmuxを利用しています。
```bash
#!/bin/sh /etc/rc.common

START=99
STOP=15

start() {
        tmux new-session -s "cloudflared-session" -d "/mnt/sda1/bin/cloudflared tunnel run --token <トークン>"
}

stop() {
        tmux send-keys -t "cloudflared-session" "C-c"
        sleep 5
}

```
`/etc/init.d/cloudflared enable`で有効になります。