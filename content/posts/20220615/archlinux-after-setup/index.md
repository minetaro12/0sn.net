---
title: "ArchLinuxインストール後の設定"
date: "2022-06-15T15:10:48+09:00"
tags: ["linux", "archlinux"]
comments: true
showToc: true
---
## 1. 一般ユーザーの作成

```
# useradd -m user
```

パスワードの設定をします。

```
# passwd user
```

## 2. sudoの設定

sudoをインストール

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

## 6. LightDMのインストール

```
$ sudo pacman -S lightdm lightdm-gtk-greeter
$ sudo systemctl enable lightdm
```

## 7. Xfce4のインストール

```
$ sudo pacman -S xfce4 xfce4-goodies
```

## 8. fcitx5のインストール

```
$ sudo pacman -S fcitx5-im fcitx5-mozc
```

`.pam_environment`に以下の記述をします。

```.pam_environment
GTK_IM_MODULE DEFAULT=fcitx
QT_IM_MODULE  DEFAULT=fcitx
XMODIFIERS    DEFAULT=@im=fcitx
```

## 9. ロケールの設定

`/etc/locale.conf`を開き下のように変更します。

```
LANG=ja_JP.UTF-8
```

Xorgでのキーボードレイアウトの設定をします。

```
$ sudo localectl set-x11-keymap jp
```

## 10. 再起動

`reboot`で再起動し、GUIでログインできればOK

---

## KDEの場合

[5. フォントのインストール](/posts/20220615/archlinux-after-setup/#5-%E3%83%95%E3%82%A9%E3%83%B3%E3%83%88%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB)の後に、LightDMではなくSDDMをインストールします。

```
$ sudo pacman -S sddm
$ sudo systemctl enable sddm
```

### KDEのインストール

```
$ sudo pacman -S plasma konsole
```

この後は[8. fcitx5のインストール](/posts/20220615/archlinux-after-setup/#8-fcitx5%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB)と同じです。
