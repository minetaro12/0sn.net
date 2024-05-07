---
title: "NetplanでDHCPのオプション設定"
date: 2024-05-07T21:46:50+09:00
tags: ["netplan","ubuntu", "linux"]
comments: true
showToc: false
---
DHCPから取得したデフォルトルートを設定したくない場合があるのでメモ

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      dhcp6: true
    eth1:
      dhcp4: true
      dhcp4:
        dhcp4-overrides:
          use-routes: false
```

他にも`use-dns`や`use-domains`等のオプションがある。  
詳しくは以下のドキュメントを参照。
- https://netplan.readthedocs.io/en/latest/netplan-yaml/#dhcp-overrides
