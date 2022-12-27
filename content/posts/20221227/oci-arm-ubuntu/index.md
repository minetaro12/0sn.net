---
title: "OCIのARMインスタンスのUbuntuをクリーンインストールしたかったけどうまくいかなかった"
date: 2022-12-27T23:04:28+09:00
tags: ["oraclecloud","linux", "ubuntu"]
comments: true
showToc: true
---
OCIのARMインスタンスのUbuntuをVMごと削除せずにやる方法を考えたけどうまくいかなかった

## 1. ISOファイルのダウンロード
今回は[ここ](https://cdimage.ubuntu.com/releases/jammy/release/)から`64-bit ARM (ARMv8/AArch64) server install image`をダウンロードします。  
適当な場所(ホームディレクトリ等)に保存してください。(今回は`/home/ubuntu/ubuntu.iso`)

## 2. GRUBのメニューが表示されるうようにする
下のコマンドを実行してメニューが表示されるようにします。

```bash
sudo sed -i /boot/grub/grub.cfg -e "s/timeout=0/timeout=5/g"
sudo sed -i /boot/grub/grub.cfg -e "s/timeout_style=hidden/timeout_style=menu/g"
```

本来`/boot/grub/grub.cfg`を直接編集するのはあまり良くないですが、`/etc/default/grub`を編集しても何故か反映されなかったのでこの方法。

## 3. コンソール接続を作成する
[前に書いた方法](/posts/20220105/oci-reinstall/#3-コンソール接続を使ってブートメニューに入る)と同じなので省略。
コンソール接続ができたら再起動をし、GRUBメニューが表示されたらキーボードの`c`を押してシェルを起動します。

## 4. ISOファイルを起動する
下のように入力します。(ISOファイルの場所は適宜置き換えてください)  
`boot`を実行すると起動します。

```
loopback loop (hd0,gpt1)/home/ubuntu/ubuntu.iso
linux (loop)/casper/vmlinuz iso-scan/filename=/home/ubuntu/ubuntu.iso toram
initrd (loop)/casper/initrd
boot
```

ここで問題発生。  
途中でインストーラがクラッシュしてしまい、インストールができないorz  
[netboot.xyzを使った方法](/posts/20220105/oci-reinstall/)でDebianをインストールするのはうまくできたのでそっちを使ったほうが良さそう。