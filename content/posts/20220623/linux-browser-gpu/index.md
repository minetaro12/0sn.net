---
title: "Linuxのブラウザでハードウェアデコードを有効にする"
date: "2022-06-23T15:41:57+09:00"
tags: ["linux", "chrome", "chromium", "firefox"]
comments: true
showToc: true
---
ThinkBook 13s Gen3(Ryzen7 5800U/Arch Linux)と、Arch Linuxを導入したIntel N95のミニPCで確認しました。  
デスクトップ環境はXorgです。

## ドライバのインストール

[ArchWiki](https://wiki.archlinux.jp/index.php/%E3%83%8F%E3%83%BC%E3%83%89%E3%82%A6%E3%82%A7%E3%82%A2%E3%83%93%E3%83%87%E3%82%AA%E3%82%A2%E3%82%AF%E3%82%BB%E3%83%A9%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3#.E3.82.A4.E3.83.B3.E3.82.B9.E3.83.88.E3.83.BC.E3.83.AB)を参考にドライバをインストールします。  
`vainfo`コマンドでハードウェアデコードが使用可能なことを確認します。

## Chrome/Chromiumの場合

起動時に`--enable-features=VaapiVideoDecoder --disable-features=UseChromeOSDirectVideoDecoder`フラグを付け加えます。  
Intel UHDだと環境変数に`LIBVA_DRI3_DISABLE=1`に設定しないと動かない場合があるようです。

{{<details "Arch Linuxでのフラグの設定">}}
`~/.config/chrome-flags.conf`もしくは`~/.config/chromium-flags.conf`に以下の内容を記述する
```
--enable-features=VaapiVideoDecoder
--disable-features=UseChromeOSDirectVideoDecoder
```
{{</details>}}

## Firefoxの場合

~~**サンドボックスを無効にする必要があるので非推奨です**~~

`about:config`で`media.ffmpeg.vaapi.enabled`をtrueにします。  
~~環境変数に`MOZ_DISABLE_RDD_SANDBOX=1`を設定してFirefoxを起動します。~~

※追記(2022/09/01)  
最近のバージョンではサンドボックスを無効にしなくても動作すると思われます。