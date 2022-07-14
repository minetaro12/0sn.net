---
title: "SSHのJオプションのメモ"
date: "2022-06-09T11:43:14+09:00"
tags: ["linux", "ssh"]
comments: true
showToc: false
---
多段SSHをする場合は`ProxyCommand`を使用する場合があったがJオプションでもっと簡単にできる

## やり方

```bash
#クライアント → 踏み台1 → ターゲット

ssh -J 踏み台1 ターゲット

#クライアント → user1@192.168.0.10 → user2@192.168.2.20

ssh -J user1@192.168.0.10 user2@192.168.2.20
```

`.ssh/config`に設定を書いている場合でもできます