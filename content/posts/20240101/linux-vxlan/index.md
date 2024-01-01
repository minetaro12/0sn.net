---
title: "LinuxでVXLAN"
date: 2024-01-01T22:31:12+09:00
tags: ["linux","vxlan"]
comments: true
showToc: true
---
[前回](/posts/20231208/linux-gretap/)とネットワーク構成は同じで、[VXLAN](https://ja.wikipedia.org/wiki/Virtual_Extensible_LAN)を使ってL2接続をしてみる。

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
[前回](/posts/20231208/linux-gretap/#ブリッジの作成)と同じなので省略。

## VXLANの作成
### host1の作業
```bash
host1:~# ip link add vxlan0 type vxlan id 100 dstport 4789 remote 192.168.122.101 dev eth0
host1:~# ip link set dev vxlan0 master br0
host1:~# ip link set up dev vxlan0
```

### host2の作業
```bash
host2:~# ip link add vxlan0 type vxlan id 100 dstport 4789 remote 192.168.122.100 dev eth0
host2:~# ip link set dev vxlan0 master br0
host2:~# ip link set up dev vxlan0
```

## 疎通確認
```bash
host1:~# ping -c5 192.168.200.2
PING 192.168.200.2 (192.168.200.2): 56 data bytes
64 bytes from 192.168.200.2: seq=0 ttl=64 time=0.412 ms
64 bytes from 192.168.200.2: seq=1 ttl=64 time=0.362 ms
64 bytes from 192.168.200.2: seq=2 ttl=64 time=0.530 ms
64 bytes from 192.168.200.2: seq=3 ttl=64 time=0.497 ms
64 bytes from 192.168.200.2: seq=4 ttl=64 time=0.375 ms

--- 192.168.200.2 ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max = 0.362/0.435/0.530 ms
host1:~# ip neigh
192.168.122.101 dev eth0 lladdr 52:54:00:1a:ec:28 REACHABLE 
192.168.122.1 dev eth0 lladdr 52:54:00:d4:74:c6 REACHABLE 
192.168.200.2 dev br0 lladdr e6:20:b8:96:d4:3e REACHABLE	<= これ
```