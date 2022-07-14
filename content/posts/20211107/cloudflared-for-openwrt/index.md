---
title: "OpenWrtでCloudflaredを動かしてみる"
date: "2021-11-07T08:31:00Z"
tags: ["linux", "cloudflare", "openwrt"]
comments: true
showToc: true
---

ルーター上でCloudflaredを動かしてみたかったのでやってみた

## ビルド方法

1\. OpenWrtのSDKをダウンロードして解凍

[ここ](https://downloads.openwrt.org/)からターゲットのSDKをダウンロードして解凍する

自分はGL-MT300N-V2で動かしたいので[これ](https://archive.openwrt.org/releases/21.02.0/targets/ramips/mt76x8/openwrt-sdk-21.02.0-ramips-mt76x8_gcc-8.4.0_musl.Linux-x86_64.tar.xz)をダウンロードした

2\. リポジトリをクローン

`packages`内に[これ](https://github.com/minetaro12/openwrt-cloudflared)を`git clone`

3\. ビルドの準備

次のコマンドを実行してパッケージをインストールする

```bash
./scripts/feeds update -a
./scripts/feeds install -a
```

`make menuconfig`を実行して`Extra packages`内の`openwrt-cloudflared`にスペースで*を入れる

4\. ビルド

次のコマンドでビルドする

`make ./package/openwrt-cloudflared/compile`

終わると`bin`内にパッケージができる

## バイナリだけ欲しい場合(推奨)

[これ](https://github.com/cloudflare/cloudflared)をクローン

`GOOS=linux GOARCH=mipsle GOMIPS=softfloat go build -trimpath -ldflags "-s -w" ./cmd/cloudflared`でビルド

アーキテクチャは必要に応じて変更してください

## 動かす

バイナリが20MBくらいあるので、exrootで拡張するかパッケージを解凍してtmp等別の場所に入れてうごかすことをおすすめします。

~~自分は`/etc/init.d/cloudflared`を作成して、起動時にバイナリをGithubからダウンロードするようにしました~~

※2022/02/09追記

起動時にダウンロードだと動かない場合があるので、`/etc/init.d/cloudflared`を作成しUSBメモリから読み込むようにしました。(tmuxが必要です)

デーモン化する場合は`/root/.cloudflared`の中身を`/etc/cloudflared`にコピーする必要があります。

```bash
!/bin/sh /etc/rc.common

START=99
STOP=15

start() {
        # commands to launch application
        tmux new-session -s cfd-ssh -d "/mnt/sda1/bin/cloudflared tunnel --hostname ssh.example.com --url ssh://localhost:22 --no-autoupdate"
}

stop() {
        # commands to kill application
        tmux send-keys -t cfd-ssh C-c
        sleep 5
}
```
