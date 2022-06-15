+++
title = "ArchLinuxのインストールメモ"
date = "2022-06-15T14:38:22+09:00"
author = "minetaro12"
authorTwitter = "" #do not include @
cover = ""
tags = ["linux", "archlinux"]
keywords = ["", ""]
description = " "
showFullContent = false
readingTime = false
hideComments = false
toc = true
archives = ["2022", "2022-06"]
+++
ライブ環境が起動しているという前提です。

## 1. キーボードレイアウトの設定

```term
# loadkeys jp106
```

## 2. 起動モードの確認

```term
# ls /sys/firmware/efi/efivars
```
ディレクトリが存在している場合はUEFIで起動しています。
BIOSとUEFIではパーティションの切り方やブートローダーのインストール方法が異なります。

## 3. インターネット接続の確認

有線でDHCPであればそのまま接続できるはずです。

無線を使う場合は[iwctl](https://wiki.archlinux.jp/index.php/Iwd#iwctl)を使います。

```term
ping archlinux.jp
```

## 4. システムクロックの更新

```term
# timedatectl set-ntp true
```

## 5. パーティション

BIOSとUEFIでやり方が異なります。

今回は`/dev/sda`にインストールします。(環境によって異なります)

### BIOS

BIOSの場合は`fdisk`を使います。

### UEFI

UEFIの場合は`gdisk`を使います。

どちらとも今回は下のようなレイアウトにしました。

スワップは適宜設定してください。

|マウントポイント|パーティション|パーティションタイプ|容量|
|-|-|-|-|
|`/mnt/boot`|`/dev/sda1`|`/boot`|500MB|
|`/mnt`|`/dev/sda2`|`/`|残りすべて|

フォーマットをします。

```term
# mkfs.fat -F 32 /dev/sda1
# mkfs.ext4 /dev/sda2
```

**今回はデュアルブートの場合は考慮していません。**

## 6. ファイルシステムのマウント

```term
# mount /dev/sda2 /mnt
# mkdir /mnt/boot
# mount /dev/sda1 /mnt/boot
```

## 7. サーバーのミラーリストの設定

次のコマンドで高速な日本のミラーを設定します。

```term
# reflector --sort rate --country Japan --latest 10 --save /etc/pacman.d/mirrorlist
```

## 8. パッケージのインストール

``` term
# pacstrap /mnt base linux linux-firmware vim dhcpcd
```

今回はエディタとdhcpcdを一緒にインストールしておきます。

## 9. fstabの生成

```term
# genfstab -U /mnt >> /mnt/etc/fstab
```

## 10. chroot

インストールしたディレクトリにchrootします。

```term
# arch-chroot /mnt
```

## 11. タイムゾーンの設定

```term
# ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
# hwclock --systohc
```

## 12. ローカリゼーション

`/etc/locale.gen`を編集して、使用するロケールをコメントアウトします。

今回は`en_US.UTF-8 UTF-8`と`ja_JP.UTF-8 UTF-8`をコメントアウトしました。

次のコマンドでロケールを生成します。

```term
# locale-gen
```

`/etc/locale.conf`でLANG環境変数を設定します。

```term
# echo LANG=en_US.UTF-8 > /etc/locale.conf
```

`/etc/vconsole.conf`でコンソールのキーマップも設定します。

```term
# echo KEYMAP=jp106 > /etc/vconsole.conf
```

## 13. ホスト名の設定

`/etc/hostname`に好きなホスト名を設定します。

```term
# echo hostname > /etc/hostname
```

`/etc/hosts`にも記述します。

```
127.0.0.1 localhost
::1       localhost
127.0.1.1 hostname.localdomain hostname
```

## 14. rootパスワードの設定

```term
# passwd
```

## 15. ブートローダーのインストール

IntelCPUの場合は`pacman -S intel-ucode`、AMDCPUの場合は`pacman -S amd-ucode`でマイクロコードをインストールします。

### BIOS

```term
# pacman -S grub
# grub-install --target=i386-pc --recheck /dev/sda
# grub-mkconfig -o /boot/grub/grub.cfg
```

### UEFI

```term
# pacman -S grub efibootmgr
# grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
# grub-mkconfig -o /boot/grub/grub.cfg
```

## 16. 再起動

再起動後ネットワークに接続するために、dhcpcdサービスを有効にしておきます。

```term
# systemctl enable dhcpcd
```

`exit`でchroot環境から抜けます。

`umount -R /mnt`でアンマウントし、`reboot`で再起動します。

再起動後にログインができればOKです。