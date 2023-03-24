---
title: "WindowsをVHDにインストールする"
date: 2023-03-24T17:52:40+09:00
tags: ["windows","vhd"]
comments: true
showToc: true
---
WindowsをVHDにインストールしてLinuxディストリと共存させたのでメモ。

## 環境
- UEFI
- Linuxディストリがインストール済み(今回はArch Linux)
- GRUB2

|ESP|VHDを入れるパーティション|Linuxディストリ|
|-|-|-|
|FAT32|NTFS|ext4等|
|S:|E:|-|

## 1. インストールメディアのコマンドプロンプトを起動
Windowsのインストールメディアから起動したら`Shift + F10`でコマンドプロンプトを起動する。

## 2. VHDを作成してフォーマット
```
X:\sources>diskpart

: 差分VHDを使う場合はできるだけ小さく作成する
DISKPART> create vdisk file=e:\windows11.vhdx maximum=30720 type=expandable
DISKPART> attach vdisk
DISKPART> list disk
: ここで作成したVHDが選択されているか確認する

DISKPART> create partition primary
DISKPART> format quick label=windows11
DISKPART> assign letter=v
DISKPART> exit
```

## 3. イメージを展開
ここではWindows11Hを展開します。
```
: インストールメディアがF:\で認識されている場合
X:\sources>dism /get-wiminfo /wimfile:f:\sources\install.wim
~
インデックス: 1
名前: Windows 11 Home
説明: Windows 11 Home
サイズ: ~バイト
~

: V:\に対してWin11Hを展開
X:\sources>dism /apply-image /imagefile:f:\sources\install.wim /index:1 /applydir:v:\
```

## 4. ブートローダーのインストール
```
: S:\のESPにブートローダーをインストール
X:\sources>bcdboot v:\windows /s s: /f uefi
X:\sources>wpeutil reboot
```

## 5. GRUB2でWindowsブートマネージャーを呼び出す設定
ここからはLinuxディストリでの作業。  
ESPのUUIDは`lsblk -f`などで調べておきます。  
`sudoedit /etc/grub.d/40_custom`

```40_custom
menuentry "Windows11" {
    search --fs-uuid --no-floppy --set=root XXXX-XXXX
    chainloader (${root})/EFI/Microsoft/Boot/bootmgfw.efi
}
```
`LANG=en_US.UTF-8 sudo grub-mkconfig -o /boot/grub/grub.cfg`

再起動し、GRUBでWindowsのエントリを選択すると起動します。

## 差分VHDを使う場合
一通りセットアップが終わったあとに親イメージを固定し、差分VHDを作成し簡単に環境の復元ができるようにします。

インストールメディアのコマンドプロンプトから実行します。
```
X:\sources>move e:\windows11.vhdx e:\windows11_base.vhdx
X:\sources>diskpart

:windows11_base.vhdxを親として差分VHDを作成
DISKPART> create vdisk file=e:\windows11.vhdx parent=e:\windows11_base.vhdx
DISKPART> exit
```
**親VHDをマウント・変更をすると差分VHDが破損するので必ず親VHDに読み取り専用属性を付けておく。**

復元を行う場合は、差分VHD(ここでは`windows11.vhdx`)を削除して、再度diskpartで`create vdisk file=e:\windows11.vhdx parent=e:\windows11_base.vhdx`を実行します。  