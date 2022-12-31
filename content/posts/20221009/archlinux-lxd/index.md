---
title: "Arch LinuxでLXDを使う"
date: "2022-10-09T15:37:04+09:00"
tags: ["linux", "arch linux", "lxd"]
comments: true
showToc: true
---
~~[Arch Linuxのリポジトリにあるパッケージ](https://www.archlinux.jp/packages/community/x86_64/lxd/)をインストールして使おうとしたところ、何故かうまく行かなかったので`snap`を使う~~

※追記：[この方法](https://wiki.archlinux.org/title/LXD#Setup_for_unprivileged_containers)で、できました

## Snapを使ったインストール(推奨)

### 1. Snapのインストール

[wiki](https://wiki.archlinux.jp/index.php/Snap)にしたがってインストールすればOK。

### 2. LXDのインストール

```
$ sudo snap install lxd

$ sudo usermod -aG lxd <username> #一般ユーザーでも実行できるように
```

## 直接インストール

### 1. LXDのインストール

```
$ sudo pacman -S lxd

$ sudo usermod -aG lxd <username> #一般ユーザーでも実行できるように
```

### 2. 名前空間の設定

```
$ echo "root:1000000:1000000000" | sudo tee /etc/subuid
$ echo "root:1000000:1000000000" | sudo tee /etc/subgid
```

## 使い方

初めに初期設定を行う必要があります。

```
$ sudo lxd init
```

基本的に全て初期設定でOKです。

```
$ lxc launch ubuntu:22.04 lxc-ubuntu #lxc-ubuntuという名前でUbuntu22.04のコンテナを作成

$ lxc launch images:archlinux lxc-arch

$ lxc launch ubuntu:20.04 vm-ubuntu --vm #vm-ubuntuという名前でUbuntu20.04の仮想マシンを作成

$ lxc start lxc-ubuntu #コンテナの起動

$ lxc stop lxc-ubuntu #コンテナの停止

$ lxc delete lxc-ubuntu #コンテナの削除

$ lxc image ls #ローカルにあるイメージを一覧表示

$ lxc remote ls #リモートの一覧を表示

$ lxc image ls images: #リモートimagesのイメージを一覧表示

$ lxc image ls images:archlinux
```

## LXDコンテナでGUIアプリを使う

[https://wiki.archlinux.jp/index.php/LXD#Use_Wayland_and_Xorg_applications](https://wiki.archlinux.jp/index.php/LXD#Use_Wayland_and_Xorg_applications)  
ホストでXorgが動いている場合の方法です  
lxc-ubuntuという名前のコンテナの例です。

### 1. GPUを使えるようにする

```
$ lxc config device add lxc-ubuntu mygpu gpu
```

### 2. ソケットの設定

先にコンテナ内で`/tmp/xorg1`ディレクトリを作成します。

```
$ lxc exec lxc-ubuntu -- su -l
# mkdir /mnt/xorg1
# logout

$ lxc config device add lxc-ubuntu Xsocket proxy \
  bind=container \
  connect=unix:/tmp/.X11-unix/X0 \
  listen=unix:/mnt/xorg1/X0 \
  uid=1000 \
  gid=1000 \
  security.gid=1000 \
  security.uid=1000 \
  mode=0777
```

### 3. コンテナ内でソケットのシンボリックリンクを張る

この操作はコンテナが起動する度に必要です。  
面倒な場合はデーモン化したりしてください。

```
$ lxc exec lxc-ubuntu -- su -l
# ln -s /mnt/xorg1/X0 /tmp/.X11-unix/X0
```

### 4. コンテナ内の環境変数を設定する

```
# echo "export DISPLAY=:0" >> .profile
# . .profile
# logout
```

### 5. 音が出るようにする

※ホスト側にpipewire-pulseまたはpulseaudioが入っている必要があります。

```
$ lxc config device add lxc-ubuntu pa disk \
  source=/run/user/1000/pulse/native \
  path=/tmp/.pulse-native 
$ lxc exec lxc-ubuntu -- su -l

# echo "export PULSE_SERVER=unix:/tmp/.pulse-native" >> .profile
# . .profile
# logout
```

### 6. ホスト側でXサーバーにアクセスできるようにする

**使い終わったら`xhost -`でもとに戻してください**

```
$ sudo pacman -S xorg-xhost
$ xhost +
```

これでGUIアプリが動くようになりました

## LXDコンテナのIPアドレスを固定する

```
$ lxc launch images:ubuntu/22.04 container
$ lxc network attach lxdbr0 container eth0 eth0
$ lxc config device set container eth0 ipv4.address=10.228.168.100
$ lxc restart container
```