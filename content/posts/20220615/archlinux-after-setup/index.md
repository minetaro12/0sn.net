---
title: "Arch Linuxインストール後の設定"
date: "2022-06-15T15:10:48+09:00"
tags: ["linux", "arch linux"]
comments: true
showToc: true
---

無線LANの場合はiwdを使ってネットワークに接続します。  
使い方は[こちら](https://wiki.archlinux.jp/index.php/Iwd#iwctl)

```
# systemctl start iwd
# iwctl
```

## 1. 一般ユーザーの作成

```
# useradd -m user
```

パスワードの設定をします。

```
# passwd user
```

## 2. sudoの設定

sudoが入っていない場合はインストール

```
# pacman -S sudo
```

`EDITOR=vim visudo`で`# %wheel ALL=(ALL) AL`をコメントを解除してください。  
ユーザーをwheelグループに追加します。

```
# usermod -aG wheel user
```

`reboot`で再起動し新しく作成したユーザーでログインします。

## 3. Xorgのインストール

```
$ sudo pacman -S xorg-server
```

## 4. ビデオドライバのインストール

### Intelの場合

```
$ sudo pacman -S xf86-video-intel
```

### AMDの場合

```
$ sudo pacman -S xf86-video-amdgpu
```

### VirtualBoxの場合

VirtualBoxで動かしている場合はビデオドライバをインストールせずにGuest Additionsをインストールしてください。

```
$ sudo pacman -S virtualbox-guest-utils
```

## 5. フォントのインストール

```
$ sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji
```

## 6. DEのインストール

### Xfce4の場合

```
$ sudo pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
$ sudo systemctl enable lightdm
```

### KDEの場合


```
$ sudo pacman -S plasma konsole sddm
$ sudo systemctl enable sddm
```

## 7. fcitx5のインストール

```
$ sudo pacman -S fcitx5-im fcitx5-mozc
```

`/etc/environment`に以下の記述をします。

```/etc/environment
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```

## 8. ロケールの設定

`/etc/locale.conf`を開き下のように変更します。

```
LANG=ja_JP.UTF-8
```

Xorgでのキーボードレイアウトの設定をします。

```
$ sudo localectl set-x11-keymap jp
```

## 9. NetworkManagerに切り替える

GUIでネットワークの設定をするためにNetworkManagerに切り替えます。

```
$ sudo pacman -S networkmanager
$ sudo systemctl disable dhcpcd
$ sudo systemctl enable NetworkManager
```

## 10. 再起動

`reboot`で再起動し、GUIでログインできればOK