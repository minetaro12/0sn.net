---
title: "Caddyとlogrotateの併用について"
date: 2024-09-11T23:07:06+09:00
tags: ["linux","caddy", "logrotate"]
comments: true
showToc: true
---
Ubuntuでnginxをインストールするとlogrotateの設定も一緒に入るので、`access.log access.log.1 access.log.2.gz...`といった感じに１日毎にログをローテーションしてくれる。  
Caddyにもログのローテーション機能はあるが毎日ローテーションする機能はない模様なので、logrotateの設定ファイルを作って似たような挙動にしてみる。
> https://caddyserver.com/docs/caddyfile/directives/log#file

## Caddyfileの設定
`/etc/caddy/Caddyfile`
```Caddyfile
:80 {
	root * /var/www/html
	file_server
	
	log {
		format console #見やすい形で保存
		output file /var/log/caddy/access.log {
			roll_disabled
		}
	}
}
```

ここでは`/var/log/caddy/access.log`に保存するようにする。  
念の為`roll_disabled`でデフォルトのローテーション機能をオフにしておく。

## logrotateの設定
`/etc/logrotate.d/caddy`
```caddy
/var/log/caddy/*.log {
  daily
  rotate 14
  copytruncate
  compress
  delaycompress
}
```
ここでは毎日ローテーションし14日分保存、遅延圧縮するように設定した。  
nginxにはログを新しくできたファイルに書き込む機能があるが、Caddyにはないので`copytruncate`オプションを使って元のファイルを維持したままローテーションできるように設定する。

## 動作確認
`sudo logrotate -d /etc/logrotate.d/caddy`を実行し、エラーが発生していないか確認する。  
`sudo logrotate -f /etc/logrotate.d/caddy`を実行すると手動でローテーションできるので、新しくファイルができていればOK

```bash
/var/log/caddy$ ls
access.log
/var/log/caddy$ sudo logrotate -f /etc/logrotate.d/caddy 
/var/log/caddy$ ls
access.log  access.log.1
```

## 参考
- [Logging: reopen logs after reload #5316](https://github.com/caddyserver/caddy/issues/5316)
- [Feature request: Log rotation based on date #1096](https://github.com/caddyserver/caddy/issues/1096)
- [ログローテートソフトウエア logrotate についてまとめ](https://qiita.com/shotets/items/e13e1d1739eaea7b1ff9)
