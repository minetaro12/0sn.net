+++
title = "code-serverをDocker Composeで動かす"
date = "2022-02-25T17:54:02+09:00"
author = "minetaro12"
authorTwitter = "" #do not include @
cover = ""
tags = ["docker", "linux", "code-server", "vscode"]
keywords = ["", ""]
description = " "
showFullContent = false
readingTime = false
comments = true
toc = true
archives = ["2022", "2022-02"]
+++
docker-composeでcode-serverを動かしてみる。

---

## 1. Dockerのインストール

まずDockerとDocker Composeをインストールする必要があります。

下の記事で解説しています。

[Ubuntu20.04へのDockerのインストール](https://0sn.net/posts/20210731/docker-install/)

## 2. ディレクトリの作成&設定

適当な場所に実行するディレクトリを作成します。

```bash
mkdir ~/code-server
```

作成したディレクトリに移動し、`coder`ディレクトリと`docker-compose.yml`を作成します。

```bash
cd ~/code-server
mkdir coder
vim docker-compose.yml
```

{{<rawhtml>}}<script src="https://gist.github.com/minetaro12/cf0ee2223d891fbc001ae6b3440cf8d0.js?file=docker-compose.yml"></script>{{</rawhtml>}}

今回の例では[自分で作成したイメージ](https://github.com/minetaro12/deploy-code-server)を使うことにします。(NodejsとHugoがインストール済み)

ARM64環境の場合は、`image`の部分を変更してください。

パスワードを設定する場合は`environment`の`password`部分を変更します。(未設定の場合はランダムなパスワードになります)

ホストで`id`を実行し`user: "uid:gid"`で書き換えます。

```term
$ id
uid=1001(ubuntu) gid=1001(ubuntu)
# この場合 user: "1001:1001"にする
```

## 3. 起動する

```bash
docker compose up -d
```

`docker-compose.yml`でパスワードを設定していない場合は確認します。

hogeの部分がランダムのパスワードになっています。

```term
$ cat coder/.config/code-server/config.yaml
bind-addr: 127.0.0.1:8080
auth: password
password: hoge
cert: false
```

パスワードを変更する場合は`config.yml`で変更します。

また、パスワード認証を無効化したい場合は`auth: password`を`auth: none`に変更します。

パスワードを変更したり無効にした場合は`docker compose restart`で再起動します。

ブラウザで`127.0.0.1:8080`にアクセスすると表示されます。

## Nginxを使ってリバースプロキシしたい場合

httpsでアクセスしたい場合はNginxでリバースプロキシを設定します。

```bash
sudo vim /etc/nginx/conf.d/nginx-code-server.conf
```

{{<rawhtml>}}<script src="https://gist.github.com/minetaro12/cf0ee2223d891fbc001ae6b3440cf8d0.js?file=nginx-code-server.conf"></script>{{</rawhtml>}}