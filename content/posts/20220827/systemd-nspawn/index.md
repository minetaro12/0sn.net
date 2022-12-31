---
title: "systemd-nspawnを使ってみた"
date: "2022-08-27T12:21:05+09:00"
tags: ["linux", "systemd", "systemd-nspawn"]
comments: true
showToc: true
---

Arch Linuxで`systemd-nspawn`を使ってみた。

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
`systemd-networkd`を使っていて`--network-veth`を指定して起動した場合は、自動的に仮想イーサネットリンクが作成されます。

## 名前解決ができない問題

**コンテナの中で操作します**

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

## machinectlで操作する

**ホスト側で操作します。**

`/var/lib/machines`の中にrootfsを解凍するか、シンボリックリンクを張ります。  
`/media/data/ubuntu`にrootfsがある場合の例

```
$ sudo ln -s /media/data/ubuntu /var/lib/machines/ubuntu
```

`systemd-networkd`を使っている場合は`machinectl`で起動すると自動的に仮想イーサネットリンクが作成されます。

### machinectlの主な使い方

```
$ sudo machinectl start ubuntu #コンテナの起動

$ sudo machinectl login ubuntu #コンソールに入る
Connected to machine ubuntu. Press ^] three times within 1s to exit session.

Ubuntu 22.04.1 LTS ubuntu pts/1

ubuntu login:

$ sudo machinectl shell ubuntu #コンテナにrootで入る
Connected to machine ubuntu. Press ^] three times within 1s to exit session.
root@ubuntu:~#

$ sudo machinectl shell user@ubuntu #コンテナにuserで入る
Connected to machine ubuntu. Press ^] three times within 1s to exit session.
user@ubuntu:~$

$ sudo machinectl reboot ubuntu #コンテナを再起動

$ sudo machinectl poweroff ubuntu #コンテナの停止
```

## 仮想イーサネットリンクのIPアドレス範囲を変更する

**ホスト側で操作します。**

```
$ sudo cp /lib/systemd/network/80-container-ve.network /etc/systemd/network/80-container-ve.network

$ sudoedit /etc/systemd/network/80-container-ve.network
```

`Address=0.0.0.0/28`となっている部分を変更します。  
ここでは`Address=172.16.10.1/24`とします。  
下にこの設定も追加します。

```
[DHCPServer]                                                                                          
PoolOffset=100
PoolSize=50
```

`sudo networkctl reload`で再読込  
コンテナを再起動、またはコンテナ内で`networkctl reload`をすると自動的に新しいIPアドレスがDHCPで取得されます。

## コンテナのIPアドレスを固定する

**※コンテナ内で`systemd-networkd`を使っている場合のみの操作です**

**コンテナの中で操作します。**

```
# cp /lib/systemd/network/80-container-host0.network /etc/systemd/network/80-container-host0.network
# vim /etc/systemd/network/80-container-host0.network
```

下のように編集します。  
アドレス部分は[ここ](#仮想イーサネットリンクのipアドレス範囲を変更する)で設定した場合のものです。

```
[Match]
Virtualization=container
Name=host0

[Network]
DNS=1.1.1.1

[Address]
Address=172.16.10.2

[Route]
Gateway=172.16.10.1
```

コンテナ内で`networkctl reload`で反映されます。