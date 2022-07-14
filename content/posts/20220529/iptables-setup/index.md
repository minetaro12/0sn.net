---
title: "iptablesのセットアップメモ"
date: "2022-05-29T21:12:47+09:00"
tags: ["linux", "iptables"]
comments: true
showToc: true
---
iptablesのセットアップメモ

Ubuntu/Debian,IPv4前提

## 1. iptablesのインストール

`sudo apt update&&sudo apt install iptables iptables-persistent`

`iptables-persistent`は設定保存のため

インストール中に`/etc/iptables/rules.v4`に設定を保存するか聞かれるのでYes

## 2. 設定 

`/etc/iptables/rules.v4`に設定を記述する

以下は最低限の設定

```rules.v4
*filter
# 受信は破棄/送信は許可/転送は破棄
-P INPUT DROP
-P OUTPUT ACCEPT
-P FORWARD DROP

# ループバックは許可
-A INPUT -i lo -j ACCEPT
# 確立された受信は許可
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# icmpを許可
-A INPUT -p icmp -j ACCEPT
# ssh接続を許可
-A INPUT -m state --state NEW -p tcp --dport 22 -j ACCEPT

## この間に追記する

##

COMMIT
```

別のポートを許可する場合(HTTPSの例)
```rule-example
-A INPUT -p tcp --dport 443 -j ACCEPT
```

## 3. 反映させる

`sudo systemctl restart netfilter-persistent`

書き方を間違えているとエラーになるので確認する
