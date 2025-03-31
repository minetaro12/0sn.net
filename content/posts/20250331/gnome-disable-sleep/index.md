---
title: "GNOMEの自動スリープを無効にする"
date: 2025-03-31T11:40:16+09:00
tags: ["linux","gnome"]
comments: true
showToc: false
---
ログイン画面で放置すると20分程で勝手にスリープに入ってしまいサーバー機では困るので無効化する。

`/etc/gdm3/greeter.dconf-defaults`を以下のように編集する。（UbuntuやDebianで確認）
```
[org/gnome/settings-daemon/plugins/power]
# - Time inactive in seconds before suspending with AC power
#   1200=20 minutes, 0=never
sleep-inactive-ac-timeout=0 #AC駆動のスリープに入るまでの時間
# - What to do after sleep-inactive-ac-timeout
#   'blank', 'suspend', 'shutdown', 'hibernate', 'interactive' or 'nothing'
# sleep-inactive-ac-type='suspend'
# - As above but when on battery
sleep-inactive-battery-timeout=0 #バッテリー駆動のスリープに入るまでの時間
# sleep-inactive-battery-type='suspend'
```

Arch Linuxでは設定ファイルが見当たらなかったので、以下のコマンドで設定をする。
```bash
$ gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
$ gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
```
