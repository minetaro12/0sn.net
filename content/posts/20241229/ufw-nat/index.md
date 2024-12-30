---
title: "UFWでNATの設定"
date: 2024-12-29T18:29:00+09:00
tags: ["linux","ufw", "nat"]
comments: true
showToc: true
---
この例では、`eth0`にWAN、`eth1`の`10.0.0.0/24`のローカルネットワークがあるとする。

## IPフォワードの有効化
`/etc/sysctl.conf`を編集して以下の内容を追記する。（ない場合は`/etc/sysctl.d/`以下にファイルを作成する）
```conf
net.ipv4.ip_forward=1
```

編集したら`sudo sysctl -p`で反映させる。

## UFWの設定
デフォルトで転送はすべて拒否するようにする。
```bash
$ sudo ufw default deny routed
```

次にローカルネットワークからの転送を許可する。
```bash
$ sudo ufw route allow in on eth1
or
$ sudo ufw route allow from 10.0.0.0/24
```

`/etc/ufw/before.rules`に以下の内容を追加して、NATの設定をする。
```
#NAT
*nat
-F
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
COMMIT
```

下のコマンドで設定の再読み込みをする。
```bash
sudo ufw reload
```
