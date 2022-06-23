+++
title = "Linuxのブラウザでハードウェアデコードを有効にする"
date = "2022-06-23T15:41:57+09:00"
author = "minetaro12"
authorTwitter = "" #do not include @
cover = ""
tags = ["linux", "chrome", "chromium", "firefox"]
keywords = ["", ""]
description = " "
showFullContent = false
readingTime = false
hideComments = false
toc = true
archives = ["2022", "2022-06"]
+++
ThinkBook 13s Gen3(Ryzen7 5800U/ArchLinux)で確認しました。

`vaapi`コマンドでハードウェアデコードが使用可能なことを確認します。

デスクトップ環境はXorgです。

## Chrome/Chromiumの場合

起動時に`--enable-features=VaapiVideoDecoder --use-gl=egl --disable-features=UseChromeOSDirectVideoDecoder`フラグを付け加えます。

## Firefoxの場合

**サンドボックスを無効にする必要があるので非推奨です**

`about:config`で`media.ffmpeg.vaapi.enabled`をtrueにします。

環境変数に`MOZ_DISABLE_RDD_SANDBOX=1`を設定してFirefoxを起動します。