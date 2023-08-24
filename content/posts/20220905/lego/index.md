---
title: "LegoでSSL/TLS証明書を管理する"
date: "2022-09-05T21:49:45+09:00"
tags: ["lego", "domain", "cloudflare"]
comments: true
showToc: true
---

certbotの代わりにLegoを使ってみます。

## インストール

Releasesからダウンロードします。  
[https://github.com/go-acme/lego](https://github.com/go-acme/lego)  
シングルバイナリなので`/usr/local/bin`に配置するだけです。

## シェルスクリプトの作成

コマンドを直接入力でもできますが、シェルスクリプトにしたほうが楽です。  
今回はCloudflareのDNSを使って証明書を取得します。  
[以前の記事](/posts/20220217/cloudflaredns-certbot/)と同じようにAPIトークンを先に取得しておきます。  
webrootモードでやることも可能です。

### Let's Encrypt

```bash
#!/bin/bash

CF_DNS_API_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
  lego --path "/etc/lego" \
  --email "example@example.com" \
  --domains "example.com" \
  --domains "*.example.com" \
  --dns cloudflare \
  -a run
```

### ZeroSSL

ZeroSSLのアクセスキーが必要です。

```bash
#!/bin/bash

ACCESS_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
JSON=$(curl -s -X POST "https://api.zerossl.com/acme/eab-credentials?access_key=$ACCESS_KEY")
EAB_KEY=$(echo "$JSON" | jq -r .eab_kid)
EAB_HMAC_KEY=$(echo "$JSON" | jq -r .eab_hmac_key)

CF_DNS_API_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
  lego --path "/etc/lego" \
  --email "example@example.com" \
  --domains "example.com" \
  --domains "*.example.com" \
  --server "https://acme.zerossl.com/v2/DV90" \
  --eab --kid "$EAB_KEY" --hmac "$EAB_HMAC_KEY" \
  --dns cloudflare \
  -a run
```

シェルスクリプトを実行すると取得ができます。  
このシェルスクリプトでは`/etc/lego`に証明書やアカウント情報が保存されます。  
アクセストークン等が含まれているのでパーミッションに注意して保存します。

## 証明書のリストを表示

```
$ lego --path /etc/lego list
```

## 証明書の更新

[先程作成したシェルスクリプト](#シェルスクリプトの作成)の`run`を`renew`に変えると、そのまま更新用スクリプトとして使えます。