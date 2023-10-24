---
title: "GRUB2でext4が認識されない場合の対処"
date: 2023-10-24T20:29:50+09:00
tags: ["linux","grub2", "ext4"]
comments: true
showToc: false
---
Arch Linuxで`mkfs.ext4`したパーティションが別のOSでインストールしたGRUB2や[Ventoy](https://github.com/ventoy/Ventoy)で認識されない場合がある  
`tune2fs -l /dev/sdX1`の`Filesystem features`で`metadata_csum_seed`が有効になっていれば、下のコマンドで無効化する

```
# tune2fs -O ^metadata_csum_seed /dev/sdX1
```