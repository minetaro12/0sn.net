---
title: "systemd-timerを使ってみる"
date: 2023-06-05T21:21:35+09:00
tags: ["systemd","systemd-timer", "linux"]
comments: true
showToc: true
---
## ユニットファイルの書き方
`/etc/systemd/system/sample.service`
```sample.service
[Unit]
Description=Sample Service

[Service]
Type=oneshot
ExecStart=<実行したいコマンドやシェルスクリプト>
```

`/etc/systemd/system/sample.timer`
```sample.timer
[Unit]
Description=Sample Timer

[Timer]
OnCalendar=Sat *-*-* 10:00:00

[Install]
WantedBy=timers.target
```

## timerファイルのOnCalendarの書き方
`曜日 年-月-日 時:分:秒`の形式で複数行書ける。  
カンマ区切りで複数指定、`..`で範囲指定ができる。
```sample.timer
# 毎日15:00に実行させたい場合
OnCalendar=*-*-* 15:00:00

# 毎週土曜日10:00に実行させたい場合
OnCalendar=Sat *-*-* 10:00:00

# 毎月10日3:00に実行させたい場合
OnCalendar=*-*-10 3:00:00

# 毎月10,20,30日4:00に実行させたい場合
OnCalendar=*-*-10,20,30 4:00:00

# 毎日10:00,11:00,12:00に実行させたい場合
OnCalendar=*-*-* 10..12:00:00
```

## タイマーの有効化
`sudo systemctl enable --now sample.timer`で有効化する。  
編集した場合は必ず`sudo systemctl daemon-reload`を実行する。

## 設定したタイマーの確認
`systemctl list-timers --all`