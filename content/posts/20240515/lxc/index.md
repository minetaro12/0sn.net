---
title: "LXCを試してみる"
date: 2024-05-15T09:57:32+09:00
tags: ["linux","lxc"]
comments: true
showToc: true
---
## LXCとは
https://ja.wikipedia.org/wiki/LXC
> LXC（英語: Linux Containers）は、1つのLinuxカーネルを実行しているコントロールホスト上で、複数の隔離されたLinuxシステム（コンテナ）を走らせる、OSレベル仮想化のソフトウェアである。

IncusやLXDはLXCのマネージャーになっています。

## インストール
### Ubuntuの場合
```bash
$ sudo apt install lxc
```

### Arch Linuxの場合
```bash
$ sudo pacman -S lxc dnsmasq
```

`/etc/default/lxc-net`に以下の内容の記述をしないとブリッジネットワークが機能しない。
```
USE_LXC_BRIDGE="true"
```
---
どちらの場合でも`ufw`等が導入されていると通信できない場合があるので、ルールを追加して対処する。(`sudo ufw allow in on lxcbr0` `sudo ufw route allow in on lxcbr0`等)  
インストールが完了したら`sudo systemctl enable --now lxc-net`でブリッジを起動させる。

## 非特権コンテナの有効化
デフォルトでは特権コンテナになってしまいあまりよろしくないので、非特権コンテナを使えるようにする。  
特権コンテナについては[こちら](https://linuxcontainers.org/ja/lxc/security/)を参照。

`/etc/subuid`と`/etc/subgid`に以下の内容を追加する。
```
root:100000:65536
```

`/etc/lxc/default.conf`に以下の内容を追加する。
```
lxc.idmap = u 0 100000 65536
lxc.idmap = g 0 100000 65536
```

## コンテナの作成
コンテナを作成するには`lxc-create`コマンドを使用する。  
以下の例では`test`という名前のコンテナを作成しています。  
途中でディストリビューションやバージョン等を聞かれるので都度入力します。

```bash
$ sudo lxc-create -t download -n test
Downloading the image index

---
DIST    RELEASE ARCH    VARIANT BUILD
---
almalinux       8       amd64   default 20240514_23:08
almalinux       8       arm64   default 20240514_23:08
almalinux       9       amd64   default 20240514_23:08
almalinux       9       arm64   default 20240514_23:08
(長いため省略)
voidlinux       current amd64   default 20240514_17:10
voidlinux       current arm64   default 20240514_17:10
---

Distribution:　<-ここからディストリビューションやバージョン等を聞かれるので入力する
ubuntu
Release:
jammy
Architecture:
amd64

Using image from local cache
Unpacking the rootfs

---
You just created an Ubuntu jammy amd64 (20240513_07:42) container.

To enable SSH, run: apt install openssh-server
No default root or user password are set by LXC.
```

あらかじめダウンロードしたいディストリビューションやバージョンがわかっている場合は、以下のようなコマンドでコンテナを作成することが可能。
```bash
$ sudo lxc-create -t download -n test -- -d ubuntu -r jammy -a amd64
```

作成しただけではコンテナは起動しないので、後述のコマンドで起動する。

## コンテナの管理
### コンテナの起動
```bash
$ sudo lxc-start -n test
```

### コンテナの停止
```bash
$ sudo lxc-stop -n test
```

### コンテナの再起動
```bash
$ sudo lxc-stop -n test -r
```

### コンテナの一覧
```bash
$ sudo lxc-ls -f
```

### コンテナにログイン
```bash
$ sudo lxc-console -n test
```

`Ctrl+a`を押した後`q`を押すとコンソールから抜けることができます。  
何も表示されない場合は`-t 0`オプションを使用して、`/dev/console`を使うようにすると表示されます。  
コンテナを作成後はパスワードが設定されていないので、先にアタッチを使ってパスワードを設定します。

### コンテナにアタッチ
```bash
$ sudo lxc-attach -n test
```

コンソールと違い、ログイン画面をスキップして`root`のシェルに入ります。

## その他
### 既存のブリッジにコンテナを接続する
`/var/lib/lxc/<コンテナ名>/config`の`lxc.net.0.link = lxcbr0`のブリッジ名を書き換える。

### コンテナを自動起動する
`/var/lib/lxc/<コンテナ名>/config`に`lxc.start.auto = 1`を追記する。  
追記したら`sudo systemctl enable lxc`で、`lxc`デーモンを自動起動するようにする。

### ブリッジネットワークのIPアドレス範囲を変更する
`/etc/default/lxc-net`に以下の設定を追加します。
```
LXC_BRIDGE="lxcbr0"
LXC_ADDR="10.0.3.1"
LXC_NETMASK="255.255.255.0"
LXC_NETWORK="10.0.3.0/24"
LXC_DHCP_RANGE="10.0.3.2,10.0.3.254"
LXC_DHCP_MAX="253"
```

設定を変更したら`sudo systemctl restart lxc-net`でブリッジを再起動して反映させます。
