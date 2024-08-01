---
title: "Arch Linuxのlibvirtで仮想マシンの電源をホストと連動させる"
date: 2024-08-01T21:19:00+09:00
tags: ["arch linux","linux","libvirt"]
comments: true
showToc: true
---
デフォルトの状態だとホストの電源を落とすと仮想マシンが強制終了されてしまうので、ホストの電源を落とした場合は仮想マシンも正しくシャットダウンするように設定を変更する。

## 設定ファイルの作成
`/etc/conf.d/libvirt-guests`に設定ファイルを作成する。

```conf
ON_BOOT=ignore
ON_SHUTDOWN=shutdown
```

`ON_BOOT`はシャットダウンした仮想マシンを起動時に再開させるかどうか
- `start`の場合は再開
- `ignore`の場合は再開させずlibvirtのautostartになっているものだけ起動する

`ON_SHUTDOWN`はホストのシャットダウンした場合の動作
- `shutdown`は仮想マシンをシャットダウンする（ゲストエージェントのインストールが必要）
- `suspend`は仮想マシンを一時停止状態にする

その他のパラメーターは以下を参照  
https://man.archlinux.org/man/extra/libvirt/libvirt-guests.8.en

## サービスの有効化
`libvirt-guests`を有効化・起動する。

```bash
$ sudo systemctl enable --now libvirt-guests
```
