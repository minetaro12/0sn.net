---
title: "Btrfsを使ってみる"
date: 2024-07-05T11:49:49+09:00
tags: ["linux","btrfs"]
comments: true
showToc: true
---

## ファイルシステムの作成
```bash
$ sudo mkfs.btrfs /dev/loop0p1
```

### 複数パーティションにまたがるbtrfsを作成（RAID0ではない）
```bash
$ sudo mkfs.btrfs /dev/loop0p1 /dev/loop1p1
```

### RAID0でbtrfsを作成
```bash
$ sudo mkfs.btrfs -d raid0 /dev/loop0p1 /dev/loop1p1
``` 

### RAID1でbtrfsを作成
```bash
$ sudo mkfs.btrfs -d raid1 /dev/loop0p1 /dev/loop1p1
```

- RAID0, RAID1, RAID10, RAID5, RAID6に対応している
- デフォルトでメタデータはRAID1になる
    - 変更したい場合は`sudo mkfs.btrfs -m raid0 -d raid0 /dev/loop0p1 /dev/loop1p1`のようにする

## サブボリュームの操作
### 作成
```bash
$ sudo btrfs subvolume create vol1
```

### 削除
```bash
$ sudo btrfs subvolume delete vol1
```
rmやrmdirでもディレクトリと同じように削除可能

### 名前の変更
mvでディレクトリと同じように変更する

### リスト表示
```bash
$ sudo btrfs subvolume list /mnt/
```

### マウント
```bash
$ sudo mount /dev/loop0p1 /mnt/ -o subvol=vol1
```
一番上の階層をマウントしたい場合は`-o subvol=/`

### デフォルトのサブボリュームの設定
```bash
$ sudo btrfs subvolume set-default 260 /mnt/
$ sudo btrfs subvolume set-default /mnt/vol1/
```

### マウント時にサブボリュームの指定をしない場合の設定
デフォルトのサブボリュームの取得
```bash
sudo btrfs subvolume get-default /mnt/
```

## スナップショットの操作
### 作成
```bash
$ sudo btrfs subvolume snapshot vol1/ snap1
$ sudo btrfs subvolume snapshot -r vol1/ snap2
```
`-r`でリードオンリーなスナップショットを作れる  
削除などのその他の操作はサブボリュームと同じ

## 圧縮
- 利用可能なのはzstd zlib lzo
```bash
$ sudo mount /dev/loop0p1 /mnt -o compress=zstd
$ sudo mount /dev/loop0p1 /mnt -o compress-force=zstd
```
下のコマンドでは、すでにあるファイルも圧縮を試みる

## デバイスの追加
```bash
$ sudo btrfs device add /dev/loop2p1 /mnt/
$ sudo btrfs balance start /mnt/
```

## デバイスの削除
```bash
$ sudo btrfs device remove /dev/loop2p1 /mnt/
```

## RAIDでディスクを交換
- 欠落が多い場合は使えない（RAID0など）
- 片方のディスクが認識できなくなった場合はdegradedでマウントする
```bash
sudo mount /dev/loop0p1 /mnt/ -o degraded
```
- 使えなくなったディスクのIDを確認する
```bash
$ sudo btrfs device usage /mnt/
```

- 2のディスクを交換する
```bash
$ sudo btrfs replace start 2 /dev/loop2p1 /mnt/
```

- データの再配置をする
```bash
$ sudo btrfs balance start /mnt/
```

## RAIDレベルの変更
```bash
$ sudo btrfs balance start -dconvert=raid1 -mconvert=raid1 /mnt
```
この例ではメタデータとデータがRAID1に変わる
