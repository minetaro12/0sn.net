---
title: "LinuxでGRETAP"
date: 2023-12-08T12:12:01+09:00
tags: ["linux","gretap", "gre"]
comments: true
showToc: true
---
LinuxでGRETAPを作成して２つのホストの`br0`をL2接続してみる。  
物理NICをブリッジすることも可能。

```
                      eth0                 eth0
                 192.168.122.100      192.168.122.101

         +-------------+                       +-------------+
         |    host1    +-----------------------+    host2    |
         +------+------+                       +------+------+
                |                                     |
     br0        |                                     |      br0
192.168.200.1   |                                     |  192.168.200.2
          ------+------                         ------+------
```

## ブリッジの作成
### host1の作業
```bash
host1:~# ip link add br0 type bridge
host1:~# ip addr add 192.168.200.1/24 dev br0
host1:~# ip link set up dev br0
```

### host2の作業
```bash
host2:~# ip link add br0 type bridge
host2:~# ip addr add 192.168.200.2/24 dev br0
host2:~# ip link set up dev br0
```

## GRETAPの作成
### host1の作業
```bash
host1:~# ip link add tap0 type gretap local 192.168.122.100 remote 192.168.122.101 
host1:~# ip link set dev tap0 master br0
host1:~# ip link set up dev tap0
```

### host2の作業
```bash
host2:~# ip link add tap0 type gretap local 192.168.122.101 remote 192.168.122.100
host2:~# ip link set dev tap0 master br0
host2:~# ip link set up dev tap0
```

## 疎通確認
```bash
host1:~# ping -c5 192.168.200.2
PING 192.168.200.2 (192.168.200.2): 56 data bytes
64 bytes from 192.168.200.2: seq=0 ttl=64 time=0.312 ms
64 bytes from 192.168.200.2: seq=1 ttl=64 time=0.348 ms
64 bytes from 192.168.200.2: seq=2 ttl=64 time=0.355 ms
64 bytes from 192.168.200.2: seq=3 ttl=64 time=0.568 ms
64 bytes from 192.168.200.2: seq=4 ttl=64 time=0.365 ms

--- 192.168.200.2 ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max = 0.312/0.389/0.568 ms
host1:~# ip neigh
192.168.200.2 dev br0 lladdr a6:d0:03:e0:e3:8d REACHABLE	<=これ
192.168.122.1 dev eth0 lladdr 52:54:00:d4:74:c6 REACHABLE 
192.168.122.101 dev eth0 lladdr 52:54:00:1a:ec:28 REACHABLE
```
ARPテーブルに表示されているのでL2レベルで接続できていることがわかる。

## NICをブリッジしたときに通信できない場合
ブリッジを介したNIC間の通信ができない場合はiptablesの操作で通信を許可する。
```bash
~# iptables -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT
```

## 参考
- https://qiita.com/mochizuki875/items/c69bb7fb2ef3a73dc1a9