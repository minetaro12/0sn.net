---
title: "Manjaroを手動インストールする"
date: 2023-07-30T23:06:40+09:00
tags: ["linux","manjaro"]
comments: true
showToc: true
---
## 1. ISOファイルをダウンロードしライブ環境を起動
https://manjaro.org/download/からISOをダウンロードしてライブ環境を起動させる。

## 2. インストールの準備
起動したら`CTRL+ALT+F2`でttyの切り替え、もしくはデスクトップ環境でターミナルを開く。  
`sudo pacman -Sy archlinux-keyring manjaro-keyring arch-install-scripts`でキーリングの更新、  
`sudo pacman-mirrors -c Japan`で日本のミラーを選択する。

後は通常のArch Linuxと同様にインストールを行う。([参考](/posts/20220615/archlinux-install/))

## Manjaroっぽくするパッケージ
手動でインストールすると素の状態なので、以下のパッケージを導入するとManjaroっぽく(?)なる

### Xfce4
- `manjaro-xfce-settings`

### Plasma
- `manjaro-icons`
- `plasma5-themes-breath`

## 独自のGUIツール
- `manjaro-settings-manager`
  - ロケールやキーマップ、カーネルの選択など
- `pamac`
  - `pacman`のGUI版