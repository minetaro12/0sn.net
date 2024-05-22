---
title: "Linuxでファイル暗号化"
date: 2024-05-21T13:52:21+09:00
tags: ["linux","encrypt", "fscrypt", "dm-crypt"]
comments: true
showToc: true
---
## fscryptを使った方法
ファイルシステムの暗号化機能を使った方法で、ext4,f2fsで利用することができます。
- https://github.com/google/fscrypt

### ファイルシステムの機能の有効化
#### ext4の場合
```bash
$ sudo tune2fs -O encrpyt /dev/sda1
```

#### f2fsの場合
```bash
$ fsck.f2fs -O encrypt /dev/sda1
or
$ mkfs.f2fs -O encrypt /dev/sda1
```

### セットアップ
以下のコマンドで`fscrypt`をセットアップします。  
root以外のユーザーにメタデータの作成を許可するか聞かれるので、ここでは`y`にしています。

```bash
$ sudo fscrypt setup
Defaulting to policy_version 2 because kernel supports it.
Customizing passphrase hashing difficulty for this system...
Created global config file at "/etc/fscrypt.conf".
Allow users other than root to create fscrypt metadata on the root filesystem? (See
https://github.com/google/fscrypt#setting-up-fscrypt-on-a-filesystem) [y/N] y
Metadata directories created at "/.fscrypt", writable by everyone.
```

ルートファイルシステムでない場所で暗号化したい場合は、上のコマンドを実行した後にマウントポイントを指定して下のコマンドも実行します。
```bash
$ sudo fscrypt setup /mnt
Allow users other than root to create fscrypt metadata on this filesystem? (See
https://github.com/google/fscrypt#setting-up-fscrypt-on-a-filesystem) [y/N] y
Metadata directories created at "/mnt/.fscrypt", writable by everyone.
```

### ディレクトリの暗号化
ここではホームディレクトリに`secret`というディレクトリを作って暗号化します。  
作成後はアンロックされているため、そのまま読み書きできます。

```bash
$ cd ~
$ mkdir ./secret
$ fscrypt encrypt ./secret
The following protector sources are available:
1 - Your login passphrase (pam_passphrase)
2 - A custom passphrase (custom_passphrase)
3 - A raw 256-bit key (raw_key)
Enter the source number for the new protector [2 - custom_passphrase]: 2 <- ここでは任意のパスワードを使う
Enter a name for the new protector: secretfiles
Enter custom passphrase for protector "secretfiles":
Confirm passphrase:
"./secret" is now encrypted, unlocked, and ready for use.

$ fscrypt status ./secret <-暗号化されていることがわかる
"./secret" is encrypted with fscrypt.

Policy:   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Options:  padding:32 contents:AES_256_XTS filenames:AES_256_CTS policy_version:2
Unlocked: Yes

Protected with 1 protector:
PROTECTOR         LINKED  DESCRIPTION
xxxxxxxxxxxxxxxx  No      custom protector "secretfiles"
```

ファイルを作成して暗号化してみます。
```bash
$ cat <<EOF > ./secret/text
> hello world
> EOF
$ fscrypt lock ./secret
"./secret" is now locked.
$ ls ./secret
Kr1vz3BKed-9NzbRDfM6Vp7MzjVjfIuKl3w_mOEB4_oOBgMyMR7FGA
$ cat ./secret/Kr1vz3BKed-9NzbRDfM6Vp7MzjVjfIuKl3w_mOEB4_oOBgMyMR7FGA
cat: ./secret/Kr1vz3BKed-9NzbRDfM6Vp7MzjVjfIuKl3w_mOEB4_oOBgMyMR7FGA: Required key not available
```
ロック後はファイルが暗号化されていることがわかります。

読み書きするためにロック解除してみます。
```bash
$ fscrypt unlock ./secret
Enter custom passphrase for protector "secretfiles": <-ここでパスワード入力
"./secret" is now unlocked and ready for use.
$ ls ./secret
text
$ cat ./secret/text
hello world
```
読み書きできるようになりました。

## dm-cryptを使った方法
dm-cryptではブロックデバイスを暗号化します。

### セットアップ
ここでは`/dev/sda1`を暗号化します。  
{{<rawhtml>}}<strong style="color:red;">この操作で指定したパーティションのデータが消えます</strong>{{</rawhtml>}}

```bash
$ sudo cryptsetup luksFormat /dev/sda1

WARNING!
========
This will overwrite data on /dev/sda1 irrevocably.

Are you sure? (Type 'yes' in capital letters): YES <-大文字でYESと入力する
Enter passphrase for /dev/sda1: <-パスワードを設定する
Verify passphrase:　<-再度パスワードを入力する

$ lsblk -f /dev/sda1
NAME FSTYPE      FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
sda1 crypto_LUKS 2           xxxxxxxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx <- LUKSでフォーマットされたことがわかる
```

### パーティションのフォーマット
ここでは`secret`という名前で開き、ext4でフォーマットします。
```bash
$ sudo cryptsetup open /dev/sda1 secret
Enter passphrase for /dev/sda1: <-暗号化時に設定したパスワードを入力
$ lsblk /dev/sda1
NAME     MAJ:MIN RM SIZE RO TYPE  MOUNTPOINTS
sda1     254:17   0   5G  0 part
└─secret 253:1    0   5G  0 crypt

$ sudo mkfs.ext4 /dev/mapper/secret <-ext4でフォーマット
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 1306368 4k blocks and 327040 inodes
Filesystem UUID: xxxxxxxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```

### 暗号化されたパーティションのマウント
```bash
$ sudo cryptsetup open /dev/sda1 secret
Enter passphrase for /dev/sda1:
$ sudo mount /dev/mapper/secret /mnt/
$ lsblk /dev/vdb1
NAME     MAJ:MIN RM SIZE RO TYPE  MOUNTPOINTS
vdb1     254:17   0   5G  0 part
└─secret 253:1    0   5G  0 crypt /mnt <-暗号化されたパーティションがマウントされた
```

### アンマウント
```bash
$ sudo umount /mnt
$ sudo cryptsetup close secret
```
