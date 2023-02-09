---
title: "Arch LinuxでL2TP/IPsecのVPNに接続(CLI版)"
date: 2023-02-09T22:11:33+09:00
tags: ["arch linux","linux", "vpn"]
comments: true
showToc: true
---
[前の記事](/posts/20220703/archlinux-l2tpipsec-client/)ではNetworkManagerを用いた方法を書いたが、今回はCLI版。  
Ubuntuなどのディストリでもパッパージ名などが違うだけで、ほとんど同じようにできるはず。

## 1. パッケージのインストール
`sudo pacman -S xl2tpd strongswan`  
+お好きなエディタ(`export EDITOR=vim`)

## 2. 設定ファイルの作成
`sudoedit /etc/ipsec.conf`
```/etc/ipsec.conf
conn vpn
  auto=add
  keyexchange=ikev1
  authby=secret
  type=transport
  left=%defaultroute
  leftprotoport=17/1701
  rightprotoport=17/1701
  right=<サーバーのホスト名>
  #rightid= #うまく行かない場合は0.0.0.0やサーバーのVPNインターフェースのIPアドレスを設定
  ike=aes128-sha1-modp2048
  esp=aes128-sha1
  #auto=start #自動接続させる場合
```
---
`sudoedit /etc/ipsec.secrets`
```/etc/ipsec.secrets
: PSK "<事前共有鍵>"
```
---
`sudoedit /etc/xl2tpd/xl2tpd.conf`
```/etc/xl2tpd/xl2tpd.conf
[lac vpn]
lns = <サーバーのホスト名>
ppp debug = yes
pppoptfile = /etc/ppp/options.l2tpd.client
length bit = yes
```
---
`sudoedit /etc/ppp/options.l2tpd.client`
```/etc/ppp/options.l2tpd.client
ipcp-accept-local
ipcp-accept-remote
refuse-eap
require-chap
noccp
noauth
mtu 1280
mru 1280
noipdefault
defaultroute
usepeerdns
connect-delay 5000
name "<username>"
password "<password>"
```

## 3. 接続
- `sudo systemctl start strongswan-starter xl2tpd`
- `sudo ipsec up vpn`
- `sudo xl2tpd-control connect-lac vpn`

### ルーティングの設定
- `sudo ip route add 10.0.0.0/8 dev ppp0`等環境に合わせて設定

### すべての通信をVPN経由にする場合
- `sudo ipsec status`で相手のIPアドレスを調べる
- `ip route`で現在のデフォルトゲートウェイを調べる
- `sudo ip route add <相手のIPアドレス> via <現在のデフォルトゲートウェイ>`
- `sudo ip route add default dev ppp0`

## 自動接続させる
- `/etc/ipsec.conf`に`auto=start`を追記
- `/etc/xl2tpd/xl2tpd.conf`に`autodial = yes`を追記

`sudoedit /etc/ppp/ip-up.d/route.sh`
```/etc/ppp/ip-up.d/route.sh
#!/bin/sh -e

if [ -n "`echo $1 | grep ppp`" ]; then
        ip route add 10.0.0.0/8 dev $1 #環境に合わせて設定
fi

exit 0
```
忘れずに`sudo chmod 755 /etc/ppp/ip-up.d/route.sh`

## 切断
`sudo systemctl stop xl2tpd strongswan-starter`