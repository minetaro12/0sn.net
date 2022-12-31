---
title: "Minecraftサーバーをsystemdで起動・終了をする"
date: "2022-08-21T14:39:06+09:00"
tags: ["linux", "minecraft", "systemd"]
comments: true
showToc: true
---
tmuxが必要です。

## 1. 起動スクリプトの作成

まずMinecraftサーバーがあるディレクトリに移動します。  
今回は`/home/ubuntu/mc-server`とし、ユーザーは`ubuntu`とします。  
Minecraftサーバーの起動と終了に必要な`boot.sh`を作成します。

{{<rawhtml>}}<script src="https://gist.github.com/minetaro12/9a73230350f5593774f2b8eab5f90b8b.js?file=boot.sh"></script>{{</rawhtml>}}

`TMUX_NAME`はtmuxのセッション名です。  
7行目の`java -jar server.jar nogui`は、サーバー本体のファイル名など環境によって適宜変更してください。

## 2. systemdのユニットファイルの作成

`/etc/systemd/system`に適当な名前でユニットファイルを作成します。  
今回は`mcserver.service`とします。

{{<rawhtml>}}<script src="https://gist.github.com/minetaro12/9a73230350f5593774f2b8eab5f90b8b.js?file=mcserver.service"></script>{{</rawhtml>}}

ユニットファイル内のユーザーや作業ディレクトリ等も、環境によって適宜変更してください。

## 3. systemdに読み込ませる

```
$ sudo systemctl daemon-reload
```

`sudo systemctl start mcserver`でMinecraftサーバーが起動し、`stop`や`restart`ではサーバー内に通知してから停止できます。  
`enable`すれば、システム起動時に自動的に立ち上げることができます。

