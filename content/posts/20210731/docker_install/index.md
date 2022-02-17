+++
title = "Ubuntu20.04へのDockerのインストール"
date = "2021-07-31T01:13:00Z"
author = "minetaro12"
authorTwitter = "" #do not include @
cover = ""
tags = ["docker", "ubuntu", "linux"]
keywords = ["", ""]
description = " "
showFullContent = false
readingTime = false
comments = true
toc = false
archives = ["2021", "2021-07"]
+++

OracleCloudのA1インスタンスで確認

必要なパッケージのインストール

`sudo apt install -y apt-transport-https ca-certificates curl software-properties-common`

GPGキーの追加

`curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`

リポジトリを追加

`sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu focal stable"`

※コードネームやアーキテクチャは環境により書き換える

パッケージのアップデート

`sudo apt update`

Dockerをインストール

`sudo apt install docker-ce`

ここから下はDockerをrootなしで動かすための作業

ユーザーをdockerグループに追加

`sudo gpasswd -a ubuntu docker`

※ユーザー名は環境により書き換える

ソケットファイルの権限を変える

`sudo chmod 666 /var/run/docker.sock`

一般ユーザーで実行できることを確認

`docker ps`

※2021/8/5追記　公式なものでcompose cliが使える

※2021/10/20修正　リンクを変更しました

（docker-composeの代わりになるもので、ほとんど同じ）

```bash
mkdir -p ~/.docker/cli-plugins
cd ~/.docker/cli-plugins
#amd64の場合
wget -O docker-compose https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64
#arm64の場合
wget -O docker-compose https://github.com/docker/compose/releases/latest/download/docker-compose-linux-aarch64
chmod +x docker-compose
```

`docker-compose`ではなく`docker compose`で使う

***

docker-composeは直接パッケージをインストールしてもうまく行かなかったため下記の方法でインストール

```bash
sudo curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

※docker-compose自体をDockerコンテナで動かしてるので一番最初に実行するとイメージのダウンロードが始まる（amd64でもarm64でも使用可能）
