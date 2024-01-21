---
title: "NetplanでUbuntuのネットワーク設定をする"
date: 2024-01-21T18:31:11+09:00
tags: ["netplan", "ubuntu", "linux"]
comments: true
showToc: true
---
## 注意点
初期設定の`00-installer-config.yaml`や`50-cloud-init.yaml`は直接編集しないようにする。  
必ずコピーして`99-config.yaml`のようなファイルで設定をする。

## 設定の反映のやり方
- `netplan apply`  
設定が即座に反映される

- `netplan try --timeout=30`  
30秒以内にEnterを押さないと設定が元に戻る(リモートで作業しているときに便利)

## DHCPでIPアドレスを取得する
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      dhcp6: true
```

## 手動でIPアドレスを設定する
```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.122.100/24
      routes:
        - to: default
          via: 192.168.122.1
      nameservers:
        addresses:
          - 192.168.122.1
```

## 物理NICをブリッジに接続する
`br0`に対して設定をする
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      dhcp6: false
  bridges:
    br0:
      dhcp4: true
      dhcp6: true
      interfaces:
        - eth0
```