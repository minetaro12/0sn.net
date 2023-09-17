---
title: "SoftEther VPNのサーバー証明書をLegoで取得する"
date: 2023-09-17T14:46:44+09:00
tags: ["softether vpn","lego", "linux"]
comments: true
showToc: true
---

SoftEther VPNにMS-SSTPを使って接続すると初期状態だと自己署名証明書のためエラーが発生する  
クライアントの信頼できるルート証明書機関に追加して回避することもできるが、面倒なのでLegoを使ってLet’s Encryptから取得する(ZeroSSL等でもOK)

## 1. Lego のインストール
[前の記事](/posts/20220905/lego/#インストール)に書いてあるので省略

## 2. 取得＆設定用シェルスクリプトの作成
今回もCloudflareのDNSを使って取得する(もちろんHTTP-01チャレンジでもOK)  
FQDNやSoftEther VPNのインストール位置は適宜修正してください  
鍵長が2048ビットでないとエラーが発生して設定できないので、必ず`--key-type rsa2048`を指定する

```bash
#!/bin/bash

CF_DNS_API_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
  lego --path "/etc/lego" \
  --email "example@example.com" \
  --domains "vpn.example.com" \
  --key-type rsa2048 \
  --dns cloudflare \
  -a run #更新する場合はrenewに変える

#証明書のセット
/usr/local/vpnserver/vpncmd \
  localhost:5555 \
  -server \
  -password:<VPNサーバーの管理者パスワード> \
  -cmd servercertset \
  -loadcert:/etc/lego/certificates/vpn.example.com.crt \
  -loadkey:/etc/lego/certificates/vpn.example.com.key

```

## 3. 実行
作成したシェルスクリプトを保存して実行する

```
sudo /etc/lego/vpn.example.com.sh
```