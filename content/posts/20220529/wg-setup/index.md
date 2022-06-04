+++
title = "WireGuardのセットアップメモ"
date = "2022-05-29T22:01:45+09:00"
author = "minetaro12"
authorTwitter = "" #do not include @
cover = ""
tags = ["linux", "wireguard", "vpn"]
keywords = ["", ""]
description = " "
showFullContent = false
readingTime = false
hideComments = false
toc = true
archives = ["2022", "2022-05"]
+++
WireGuardの設定のメモ

Ubuntu/Debian iptables環境前提

## 1. インストール

`sudo apt update&&sudo apt install wireguard`

## 2. 鍵の作成

WireGuardはサーバーとクライアント両方で公開鍵と秘密鍵のペアが必要です

```term
$ sudo su
# cd /etc/wireguard
# wg genkey > wgserver.key #サーバーの秘密鍵作成
# wg pubkey < wgserver.key > wgserver.pub #サーバーの公開鍵作成
# wg genkey > wgclient.key #クライアントの秘密鍵作成
# wg pubkey < wgclient.key > wgclient.pub #クライアントの公開鍵作成

# chmod 600 wgserver.key
# chmod 600 wgclient.key
```

## 3. 設定

ポートフォワードを有効にする必要がある

```term
# echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
# sysctl -p
net.ipv4.ip_forward = 1
```

---

`/etc/wireguard/wg0.conf`を作成する

VPNのインターフェースは`192.168.10.1/24`

50000番で待ち受け

クライアントは`192.168.10.2`とする

PostUp PostDownはNATの設定なのでインターフェース名は適宜変更する

クライアントを追加する場合は、Peerを追加する

```conf
[Interface]
Address = 192.168.10.1/24 #VPNインターフェースで使うIPアドレス
PrivateKey = #wgserver.keyの内容
ListenPort = 50000
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = #wgclient.pubの内容
AllowedIPs = 192.168.10.2/32 #クライアントに割り当てるIPアドレス
```

---

50000番で待ち受けるのでiptablesのは下のように設定(UDPなので注意)

```iptables
-A INPUT -p udp --dport 50000 -j ACCEPT
```

WireGuard経由でインターネットに出たり、クライアント同士で通信するには以下の設定が必要

インターフェース名は適宜変更してください

```iptables
-A FORWARD -i wg0 -o eth0 -j ACCEPT
-A FORWARD -i eth0 -o wg0 -j ACCEPT
-A FORWARD -i wg0 -o wg0 -j ACCEPT
```

## 4. 起動

```term
$ sudo systemctl enable wg-quick@wg0
$ sudo systemctl start wg-quick@wg0
```

## 5. クライアントの設定

クライアントにもWireGuardをインストール

`/etc/wireguard/wg0.conf`を作成する

```conf
[Interface]
PrivateKey = #wgclient.keyの内容
Address = 192.168.10.2/32 #サーバー側で割り当てたクライアント用IPアドレス
#DNS = 1.1.1.1

[Peer]
PublicKey = #wgserver.pubの内容
AllowedIPs = 192.168.0.0/24, 192.168.10.0/24 #WireGuardを経由するIPアドレス,範囲
EndPoint = #サーバーのIPアドレス:ポート
```

PeerのAllowedIPsで`0.0.0.0/0`を指定するとすべての通信がWireGuard経由になる

サーバーからクライアント、クライアントからクライアントを通すにはAllowedIPsにVPNインターフェースのアドレスを指定する必要がある(ここでは`192.168.10.0/24`)

`sudo wg-quick up wg0`で接続

`sudo wg-quick down wg0`で切断
