+++
title = "Ubuntu22.04へのDockerのインストール"
date = "2022-06-11T17:40:36+09:00"
author = "minetaro12"
authorTwitter = "" #do not include @
cover = ""
tags = ["docker", "ubuntu", "linux"]
keywords = ["", ""]
description = " "
showFullContent = false
readingTime = false
hideComments = false
toc = false
archives = ["2022", "2022-06"]
+++

Ubuntu20.04とGPGキーの追加の方法が違います。

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

リポジトリの追加

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
```

これ以降は、[こちら](/posts/20210731/docker-install/)と同じです。