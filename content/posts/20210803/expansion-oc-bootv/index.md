---
title: "OracleCloudのブートボリュームの拡張"
date: "2021-08-03T08:44:00Z"
tags: ["oraclecloud", "linux"]
comments: true
showToc: false
---
※Ubuntu20.04LTSにて確認しました

1\. OracleCloudのWebコンソールの左上のメニュー→ストレージ→ブロックストレージ→ブートボリュームに進む

2\. 変更したいブートボリュームの右のボタンを押し編集

3\. ボリュームサイズを任意のサイズに変更（無料枠では全部合わせて200GBまで）

4\. ブートボリュームを使用しているインスタンスにSSHログイン

5\. lsblkを実行し現在のサイズを確認

```bash
$ lsblk
sda       8:0    0    47G  0 disk 
├─sda1    8:1    0  46.9G  0 part /
└─sda15   8:15   0    99M  0 part /boot/efi
```

6\. 以下のコマンドを実行しボリュームを再スキャンする

```bash
$ sudo dd iflag=direct if=/dev/sda of=/dev/null count=1
1+0 records in
1+0 records out
512 bytes copied, 0.000519334 s, 986 kB/s
 
$ echo "1" | sudo tee /sys/class/block/sda/device/rescan
1
```

拡張したいブートボリュームは/dev/sdaなのでsdaを指定

7\.  再度lsblkを実行する

```bash
$ lsblk
sda       8:0    0   106G  0 disk 
├─sda1    8:1    0  46.9G  0 part /
└─sda15   8:15   0    99M  0 part /boot/efi
```

sdaのサイズが3で変更したサイズになっているが、sda1のサイズは変わっていない

8\. growpartでパーティションのサイズを変更する

```bash
$ sudo growpart /dev/sda 1
```

再度lsblkを実行するとパーティションのサイズが大きくなっている

```bash
$ lsblk
sda       8:0    0   106G  0 disk 
├─sda1    8:1    0 105.9G  0 part /
└─sda15   8:15   0    99M  0 part /boot/efi
```
