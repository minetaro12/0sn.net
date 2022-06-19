+++
title = "ArchLinuxインストール後の設定"
date = "2022-06-15T15:10:48+09:00"
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
## 1. 一般ユーザーの作成

```term
# useradd -m user
```

パスワードの設定をします。

```term
# passwd user
```

## 2. sudoの設定

sudoをインストール

```term
# pacman -S sudo
```

`EDITOR=vim visudo`で`# %wheel ALL=(ALL) AL`をコメントを解除してください。

ユーザーをwheelグループに追加します。

```term
# usermod -aG wheel user
```

`reboot`で再起動し新しく作成したユーザーでログインします。

## 3. Xorgのインストール

```term
$ sudo pacman -S xorg-server
```

## 4. ビデオドライバのインストール

### Intelの場合

```term
$ sudo pacman -S xf86-video-intel
```

### AMDの場合

```term
$ sudo pacman -S xf86-video-amdgpu
```

### VirtualBoxの場合

VirtualBoxで動かしている場合はビデオドライバをインストールせずにGuest Additionsをインストールしてください。

```term
$ sudo pacman -S virtualbox-guest-utils
```

## 5. フォントのインストール

```term
$ sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji
```

## 6. LightDMのインストール

```term
$ sudo pacman -S lightdm lightdm-gtk-greeter
$ sudo systemctl enable lightdm
```

## 7. Xfce4のインストール

```term
$ sudo pacman -S xfce4 xfce4-goodies
```

## 8. fcitx-mozcのインストール

```term
$ sudo pacman -S fcitx-mozc fcitx-configtool
```

`.pam_environment`に以下の記述をします。

```.pam_environment
GTK_IM_MODULE DEFAULT=fcitx
QT_IM_MODULE  DEFAULT=fcitx
XMODIFIERS    DEFAULT=@im=fcitx
```

## 9. ロケールの設定

`/etc/locale.conf`を開き下のように変更します。

```locale.conf
LANG=ja_JP.UTF-8
```

Xorgでのキーボードレイアウトの設定をします。

```term
$ sudo localectl set-x11-keymap jp
```

## 10. 再起動

`reboot`で再起動し、GUIでログインできればOK

---

## KDEの場合

[5. フォントのインストール](/posts/20220615/archlinux-after-setup/#5-%E3%83%95%E3%82%A9%E3%83%B3%E3%83%88%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB)の後に、LightDMではなくSDDMをインストールします。

```term
$ sudo pacman -S sddm
$ sudo systemctl enable sddm
```

### KDEのインストール

```term
$ sudo pacman -S plasma konsole
```

### fcitx-mozcのインストール

```term
$ sudo pacman -S fcitx-mozc fcitx-configtool kcm-fcitx
```

`.pam_environment`に以下の記述をします。

```.pam_environment
GTK_IM_MODULE DEFAULT=fcitx
QT_IM_MODULE  DEFAULT=fcitx
XMODIFIERS    DEFAULT=@im=fcitx
```

この後は[9. ロケールの設定](/posts/20220615/archlinux-after-setup/#9-%E3%83%AD%E3%82%B1%E3%83%BC%E3%83%AB%E3%81%AE%E8%A8%AD%E5%AE%9A)と同じです。

fcitxが自動起動しない場合は、設定から`fcitx-autostart`を自動起動に追加します。