---
title: "systemd-nspawnを使ってみた"
date: "2022-08-27T12:21:05+09:00"
tags: ["linux", "systemd", "systemd-nspawn"]
comments: true
showToc: true
---

ArchLinuxで`systemd-nspawn`を使ってみた。

[wiki](https://wiki.archlinux.jp/index.php/Systemd-nspawn)のやり方でUbuntuを入れることもできるが、今回はLXDのイメージをそのまま使う。

## 1. イメージのダウンロード

[ここ](https://us.lxd.images.canonical.com/images/)から使いたいディストリの`rootfs.tar.xz`をダウンロードする。

その後、ディレクトリを作成しそこに解凍する。(解凍する時は必ずsudoをつけること)

今回はUbuntu 22.04をダウンロードした。

```
$ curl https://us.lxd.images.canonical.com/images/ubuntu/jammy/amd64/default/20220826_07:42/rootfs.tar.xz -O
$ mkdir ubuntu
$ sudo tar xJvf rootfs.tar.xz -C ubuntu
```
Debian系ディストリのLXDイメージはこのままでは`Failed to read machine ID from container image: Invalid argument`となって動かせないので、下の操作をする。

```
$ sudo rm ubuntu/etc/machine-id
```

## 2. chrootしてrootパスワードを設定する

```
$ sudo systemd-nspawn -D ubuntu
# passwd
# logout
```
## 3. 起動する

```
$ sudo systemd-nspawn -bD ubuntu
```

ここでログインプロンプトが表示されるので`root`で先程設定したパスワードでログインする。

## 名前解決ができない問題

コンテナの中で操作します

```
# vim /etc/systemd/resolved.conf
```

ここで`DNS=1.1.1.1`等を設定します。

```
# systemctl restart systemd-resolved
# ping 0sn.net
PING 0sn.net (104.21.73.60) 56(84) bytes of data.
64 bytes from 104.21.73.60 (104.21.73.60): icmp_seq=1 ttl=56 time=17.9 ms
64 bytes from 104.21.73.60 (104.21.73.60): icmp_seq=2 ttl=56 time=37.2 ms
```

名前解決ができるようになりました。