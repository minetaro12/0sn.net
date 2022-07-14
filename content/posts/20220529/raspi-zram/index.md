---
title: "RaspberryPiでZramを使う"
date: "2022-05-29T15:08:27+09:00"
tags: ["raspberrypi", "linux", "zram"]
comments: true
showToc: false
---
ラスパイでZramを有効にするメモ

Raspberry Pi OS Lite(bullseye)で確認

`/usr/bin/zram.sh`で以下の内容を書き込む

```bash
#!/bin/bash

export LANG=C

cores=$(nproc --all)

# disable zram
core=0
while [ $core -lt $cores ]; do
    if [[ -b /dev/zram$core ]]; then
        swapoff /dev/zram$core
    fi
    let core=core+1
done
if [[ -n $(lsmod | grep zram) ]]; then
    rmmod zram
fi
if [[ $1 == stop ]]; then
    exit 0
fi

# disable all
swapoff -a

# enable zram
modprobe zram num_devices=$cores

echo lz4 > /sys/block/zram0/comp_algorithm

totalmem=$(free | grep -e "^Mem:" | awk '{print $2}')
mem=$(( $totalmem * 128 ))

core=0
while [ $core -lt $cores ]; do
    echo $mem > /sys/block/zram$core/disksize
    mkswap /dev/zram$core
    swapon -p 5 /dev/zram$core
    let core=core+1
done
```

`/etc/systemd/system/zram.service`に以下の内容を書き込む

```.service
[Unit]
Description=zram Service

[Service]
Type=simple
ExecStart=/usr/bin/zram.sh

[Install]
WantedBy=multi-user.target
```

`sudo systemctl daemon-reload`
`sudo systemctl enable zram`
`sudo systemctl start zram`で有効にする

再起動後も有効になっていればOK