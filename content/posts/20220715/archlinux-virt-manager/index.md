---
title: "Arch Linuxでvirt-managerを使う"
date: "2022-07-15T11:41:03+09:00"
tags: ["arch linux", "linux", "virt-manager"]
comments: true
showToc: true
---
## 1. virt-managerと必要なパッケージをインストール

```
$ paru -S virt-manager qemu dnsmasq
```

## 2. 一般ユーザーでも使えるようにする
このままだとrootユーザーでしか使えないので一般ユーザーでも使えるようにする。

### QEMUの設定
```
$ sudoedit /etc/libvirt/qemu.conf
```

下のように変更する
- `user = "username"` usernameを普段使うユーザー名にする
- `group="libvirt"`
- `dynamic_ownership = 1`

`/dev/kvm`が使えるようにユーザーを`kvm`グループに追加する。

```
$ sudo gpasswd -a username kvm
```

### libvirtの設定
```
$ sudoedit /etc/libvirt/libvirtd.conf
```

下のように変更する
- `unix_sock_group = "libvirt"`
- `unix_sock_ro_perms = "0777"`
- `unix_sock_rw_perms = "0770"`
- `auth_unix_ro = "none"`
- `auth_unix_rw = "none"`

ユーザーを`libvirt`に追加する。
```
$ sudo gpasswd -a username libvirt
```

`libvirtd`を起動する。
```
$ sudo systemctl enable libvirtd
$ sudo systemctl start libvirtd
```

変更を反映させるため再起動する。
