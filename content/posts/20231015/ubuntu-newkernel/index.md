---
title: "Ubuntuで新しいバージョンのカーネルを使う"
date: 2023-10-15T21:23:28+09:00
tags: ["linux","ubuntu", "kernel"]
comments: true
showToc: true
---
Ubuntu 22.04がN95を載せたPCで画面出力が正常にできない等のカーネルのバージョン起因の問題が起きたりするので、新しいバージョンのカーネルを使う方法のメモ

## 1. カーネルのダウンロード
Ubuntu向けのビルド済みファイルは https://kernel.ubuntu.com/mainline/ にあるので使いたいバージョンのパッケージをダウンロードする  
今回は執筆時点での最新LTSバージョンの[6.1.57](https://kernel.ubuntu.com/mainline/v6.1.57/)を使う

x86_64であれば以下のパッケージをダウンロードする
```
amd64/linux-headers-6.1.57-060157_6.1.57-060157.202310101755_all.deb
amd64/linux-image-unsigned-6.1.57-060157-generic_6.1.57-060157.202310101755_amd64.deb
amd64/linux-modules-6.1.57-060157-generic_6.1.57-060157.202310101755_amd64.deb
```

## 2. インストール
ダウンロードしたパッケージをすべてインストールする
```
$ sudo apt install ./linux-{headers,image-unsigned,modules}-6.1.57-*.deb
```

## 3. 再起動
インストールすれば自動的にGRUBの設定が更新されるので終わったら再起動する  
デフォルトでインストールしたカーネルになっているのでそのまま起動できればOK