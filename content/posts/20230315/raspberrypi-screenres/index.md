---
title: "Raspberry Piの画面解像度の設定"
date: 2023-03-15T09:39:35+09:00
tags: ["raspberrypi","linux"]
comments: true
showToc: true
---
久しぶりに触ったら`config.txt`が変わっていて迷ったのでメモ。

## 環境
- 本体: Raspberry Pi 3B+
- OS: Raspberry Pi OS Lite

[ここ](https://www.raspberrypi.com/documentation/computers/config_txt.html#hdmi_mode)から解像度を選んで`config.txt`に書き込む。  
例えば1920x1080 60Hzのモニターに接続する場合は下のようにする。

```txt
hdmi_group=2
hdmi_mode=82
```

## 使いたい解像度がリストにない場合
480x320 60Hzのモニターの場合は下のようにする。

```txt
hdmi_group=2
hdmi_mode=87
hdmi_cvt=480 320 60
```

## 何故か画面が表示されない場合
下のような設定を追加する。  
自分のモニタでは`dtoverlay=vc4-kms-v3d`が有効になっていると画面が表示されなくなったのでコメントアウトした。

```txt
hdmi_force_hotplug=1
#dtoverlay=vc4-kms-v3d
```
