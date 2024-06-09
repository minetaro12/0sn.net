---
title: "LVMを使ってみる"
date: 2024-06-09T23:21:13+09:00
tags: ["linux","lvm"]
comments: true
showToc: true
---
https://wiki.archlinux.jp/index.php/LVM
> 論理ボリュームマネージャ (Logical Volume Manager, LVM) とは、Linux カーネルに論理ボリューム管理を提供するデバイスマッパーフレームワークです。

試したい場合はループバックデバイスを使うと便利
```bash
$ truncate -s 1G disk.img disk2.img
$ sudo losetup -fP disk.img
$ sudo losetup -fP disk2.img
```

## 物理ボリュームの操作
### 作成
```bash
$ sudo pvcreate /dev/loop0p1 /dev/loop1p1
```

### 拡大
```bash
$ sudo pvresize /dev/loop0p1
```

### 縮小
```bash
$ sudo pvresize --setphysicalvolumesize 500M /dev/loop0p1
```

### 削除
```bash
$ sudo pvremove /dev/loop0p1 /dev/loop1p1
```

## ボリュームグループの操作
### 作成
物理ボリュームの上につくる
```bash
$ sudo vgcreate volgroup /dev/loop0p1
```

### 名前の変更
```bash
$ sudo vgrename volgroup myvg
```

### 物理ボリュームを追加
- volgroupグループに/dev/loop1p1を追加する

```bash
$ sudo vgextend volgroup /dev/loop1p1
```

### 物理ボリュームを外す
```bash
$ sudo vgreduce volgroup /dev/loop1p1
``` 

### 削除
```bash
$ sudo vgremove volgroup
```

## 論理ボリュームの操作
### 作成
- 1GBで作成する例
```bash
$ sudo lvcreate -L 1G volgroup -n myvol
```

- 割合で指定して作成
```bash
$ sudo lvcreate -l 100%FREE volgroup -n myvol
```

`%VG` ボリュームグループ全体に対する割合  
`%FREE` ボリュームグループの空き容量に対する割合  
`%PVS` 物理ボリュームに対する割合  
`%ORIGIN` 元の論理ボリュームの合計サイズ（スナップショット用）に対する割合

### 名前の変更
```bash
$ sudo lvrename volgroup/myvol rootvol
```

### 拡大
```bash
$ sudo lvresize -L +1G --resizefs volgroup/myvol
```
この例では1GB増やすとともにファイルシステムの拡大もする

```bash
$ sudo lvresize -l +100%FREE --resizefs volgroup/myvol
```
ボリュームグループの空き容量を埋めるまで拡大しファイルシステムも拡大する

### 縮小
先にファイルシステムを最小まで縮小する
```bash
$ sudo resize2fs -M /dev/volgroup/myvol
```

ボリュームを200MBに縮小する
```bash
$ sudo lvresize -L 200M volgroup/myvol
```

再度ファイルシステムを拡大する
```bash
$ sudo resize2fs /dev/volgroup/myvol
```

### 削除
```bash
$ sudo lvremove volgroup/myvol
```

## スナップショット
`volgroup/myvol`のスナップショットを`snap1`という名前で作成（100MBのデータ変更まで）
```bash
$ sudo lvcreate --size 100M --snapshot -n snap1 volgroup/myvol
```

`snap1`を作成した時点に戻す（`snap1`は消える）
```bash
$ sudo lvconvert --merge volgroup/snap1
```

## 取り外し（エクスポート）
ボリュームグループを非アクティブ化する
```bash
$ sudo vgchange -a n volgroup
```

エクスポートする
```bash
$ sudo vgexport volgroup
```
`sudo pvscan`で`is in exported VG volgroup`になっていればOK

## 取り付け（インポート）
`sudo pvscan`でインポートしたいボリュームグループを探す（ここでは`volgroup`）

下のコマンドでインポートする
```bash
$ sudo vgimport volgroup
```

論理ボリュームをアクティブ化する（`sudo lvscan`で`inactive`のものを探す）
```bash
$ sudo lvchange -a y volgroup/myvol
```

`sudo lvscan`で`ACTIVE`になればOK

## シンプロビジョニング
`volgroup`に`thinpool`という名前でシンプールを作成  
**メタデータ用に大きさを95%に設定する**
```bash
$ sudo lvcreate --type thin-pool -n thinpool -l 95%FREE volgroup
```

シンプール内に100GBの論理ボリュームを作成
```bash
$ sudo lvcreate -n myvol1 -V 100G --thinpool volgroup/thinpool
```

## RAID
https://man.archlinux.org/man/lvmraid.7  
先に通常通り物理ボリュームとボリュームグループを作成する

### RAID1
```bash
$ sudo lvcreate --type raid1 --mirrors 1 -l 100%FREE -n myvol volgroup /dev/loop0p1 /dev/loop1p1
```

### RAID0
```bash
$ sudo lvcreate --type raid0 --stripes 2 -l 100%FREE -n myvol volgroup /dev/loop0p1 /dev/loop1p1
```

### RAID10
```bash
$ sudo lvcreate --type raid10 --stripes 2 --mirrors 1 -l 100%FREE -n myvol volgroup /dev/loop0p1 /dev/loop1p1 /dev/loop2p1 /dev/loop3p1
```

### ステータス確認
```bash
$ sudo lvs -o name,segtype,devices
  LV    Type   Devices
  root  linear /dev/vda3(0)
  myvol raid10 myvol_rimage_0(0),myvol_rimage_1(0),myvol_rimage_2(0),myvol_rimage_3(0)

$ sudo lvs -o name,lv_health_status
  LV    Health
  root
  myvol
```

### ディスク交換
`lv_health_status`が`partial`になっていればディスクが欠落している状態

新しいディスクの追加
```bash
$ sudo pvcreate /dev/loop4p1
$ sudo vgextend volgroup /dev/loop4p1
```

新しく追加したディスクに入れ替える
```bash
$ sudo lvconvert --repair volgroup/myvol /dev/loop4p1
```

まだ壊れたディスクのデバイス名が表示されている場合は下のコマンドを使う
```bash
$ sudo lvconvert --replace OldPV VG/LV newPV
```

壊れたディスクを削除する
```bash
$ sudo vgreduce --removemissing volgroup
```
