---
title: "Arch LinuxでAvahiを使う"
date: 2023-08-11T17:12:44+09:00
tags: ["arch linux","linux", "avahi", "mdns"]
comments: true
showToc: true
---
`systemd-networkd`と`systemd-resolved`の環境で`Avahi`を使ってみる  
`systemd-resolved`にmDNSの機能があるが、Windows相手だと何故か名前解決が激遅になるので今回は使わない

## 1. インストール
```bash
$ paru -S avahi nss-mdns
```

## 2. systemd-resolvedの設定
```bash
$ sudoedit /etc/systemd/resolved.conf
```
ここで`MulticastDNS=no`と`LLMNR=no`を設定する

```bash
$ sudo systemctl restart systemd-resolved
```

## 3. nsswitch.confの設定
```bash
$ sudoedit /etc/nsswitch.conf
```
次のように設定する

```
hosts: mymachines mdns4_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns
```

## 4. Avahiの起動
```bash
$ sudo systemctl enable --now avahi-daemon
```