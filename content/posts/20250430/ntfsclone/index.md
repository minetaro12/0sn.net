---
title: "ntfscloneでNTFSパーティションをバックアップする"
date: 2025-04-30T09:16:54Z
tags: ["windows","linux", "ntfs"]
comments: true
showToc: true
---
ext4をe2imageでバックアップやクローンができるように、ntfscloneを使うとlinux環境からNTFSをバックアップできることを知ったのでメモ

## インストール
```bash
#Ubuntuの場合
$ sudo apt install ntfs-3g

#Arch Linuxの場合
$ sudo pacman -S ntfs-3g
```

ここでは、`/dev/loop0`をNTFSのパーティションとします

## NTFSパーティションを特殊イメージ化
`/dev/loop0`のNTFSを`backup.img`としてバックアップする例
```bash
$ sudo ntfsclone -s /dev/loop0 -o backup.img
ntfsclone v2022.10.3 (libntfs-3g)
NTFS volume version: 3.1
Cluster size       : 4096 bytes
Current volume size: 1073737728 bytes (1074 MB)
Current device size: 1073741824 bytes (1074 MB)
Scanning volume ...
100.00 percent completed
Accounting clusters ...
Space in use       : 6 MB (0.6%)
Saving NTFS to image ...
100.00 percent completed
Syncing ...
```
ここで作成したイメージは**特殊な形式**なので、そのままマウントしたりddコマンドで復元する場合は後述の操作が必要になります

## 特殊イメージからパーティションに復元
先ほど作成した`backup.img`から`/dev/loop1`に復元する例
```bash
$ sudo ntfsclone -r backup.img -O /dev/loop1
ntfsclone v2022.10.3 (libntfs-3g)
Ntfsclone image version: 10.1
Cluster size           : 4096 bytes
Image volume size      : 1073737728 bytes (1074 MB)
Image device size      : 1073741824 bytes
Space in use           : 6 MB (0.6%)
Offset to image data   : 56 (0x38) bytes
Restoring NTFS from image ...
100.00 percent completed
Syncing ...
```

バックアップ時よりも小さいパーティションに復元する場合は失敗するため、バックアップ前にパーティションサイズを縮小する必要があります（Linux環境で`ntfsresize`でも縮小できるが、Windowsでリサイズした方が安全だと思います）

## 特殊イメージを生イメージに復元
前述のとおり`ntfsclone`で作ったイメージは特殊な形式のため、下の操作で生イメージ（？）にすることでそのままマウントしたり、ddコマンドで復元ができるようになる

`backup.img`を生イメージの`raw.img`に変換する例
```bash
$ ntfsclone -r backup.img -o raw.img
ntfsclone v2022.10.3 (libntfs-3g)
Ntfsclone image version: 10.1
Cluster size           : 4096 bytes
Image volume size      : 1073737728 bytes (1074 MB)
Image device size      : 1073741824 bytes
Space in use           : 6 MB (0.6%)
Offset to image data   : 56 (0x38) bytes
Restoring NTFS from image ...
100.00 percent completed
Syncing ...

$ sudo mount backup.img /mnt/ # <-特殊イメージはそのままマウントできない
mount: /mnt: wrong fs type, bad option, bad superblock on /dev/loop3, missing codepage or helper program, or other error.
       dmesg(1) may have more information after failed mount system call.

$ sudo mount raw.img /mnt/ # <-生イメージはそのままマウントできる
```
