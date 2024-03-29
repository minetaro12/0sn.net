---
title: "Ubuntu22.04へのDockerのインストール"
date: "2022-06-11T17:40:36+09:00"
tags: ["docker", "ubuntu", "linux"]
comments: true
showToc: false
---

Ubuntu20.04とGPGキーの追加の方法が違います。

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

リポジトリの追加

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
```

インストール

```term
$ sudo apt update
$ sudo apt install docker-ce docker-compose-plugins
```

一般ユーザーでも実行できるようにdockerグループに追加

```
$ sudo groupadd docker #グループがない場合
$ sudo gpasswd -a ubuntu docker
```
