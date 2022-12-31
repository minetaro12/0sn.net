---
title: "PostgresqlをWAL-Gでバックアップ&リストア"
date: "2021-10-13T22:52:00Z"
tags: ["linux", "ubuntu", "wal-g", "postgresql"]
comments: true
showToc: true
---

こちらのサイトを参考にしました。

[WAL-GでオブジェクトストレージにPostgreSQLをバックアップしよう](https://blog.noellabo.jp/entry/2019/03/05/yMjQeU9JXHxcyHTL)  
[MastodonのPostgreSQLのDatabaseをWAL-Gでオブジェクトストレージにバックアップ](https://qiita.com/atsu1125/items/676d24c0473ad94b3f2b)  
[WAL-G で PostgreSQL の Backup や Replica 作成](https://blog.1q77.com/2019/06/wal-g/)

***

## 環境

OracleCloudのA1インスタンス  
Ubuntu20.04LTS  
PostgreSQL12

Misskeyのデータベースをバックアップします

***

### 1. WAL-Gをインストールする

[ここ](https://github.com/wal-g/wal-g/releases)からバイナリをダウンロードして/usr/local/binに配置  
ARM64向けはないので[ここ](https://github.com/wal-g/wal-g/blob/master/docs/PostgreSQL.md)を参考にビルドする  
実行権限を付与する

### 2. 環境変数の設定

上記のサイトを参考に/usr/local/binにwal-g.shを配置  
オブジェクトストレージを使用するので次のように書き込む

```bash
#!/bin/bash

export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_ENDPOINT="https://s3.example.com"
export WALG_S3_PREFIX="s3://backetname/"
#export AWS_S3_FORCE_PATH_STYLE="true"
export PGPORT="5432"
export PGHOST="/var/run/postgresql"
export WALG_COMPRESSION_METHOD="brotli"
 
exec /usr/local/bin/wal-g "$@"
```

`AWS_S3_FORCE_PATH_STYLE`はオブジェクトストレージのURLの形式が`https://s3.example.com/backetname`のようになってる場合に設定する

```bash
sudo chmod +x /usr/local/bin/wal-g.sh
```

必ず実行権限を付与する

### 3. フルバックアップしてみる

```bash
sudo -u postgres wal-g.sh backup-push /var/lib/postgresql/12/main
```

これでオブジェクトストレージにフルバックアップされる

```bash
wal-g.sh backup-list
```

これでバックアップができていれば成功

### 4. 差分バックアップの設定

/etc/postgresql/12/main/conf.d/archive.confを作成し次のように書き込む

```
archive_mode: on
archive_command: '/usr/local/bin/wal-g.sh wal-push %p'  
archive_timeout: 60
wal_level: replica
restore_command: '/usr/local/bin/wal-g.sh wal-fetch "%f" "%p"'
```

ここでは60秒間隔で設定した

```bash
sudo systemctl restart postgresql
tail -f /var/log/postgresql/postgresql-12-main.log
```

エラーが出ずにバックアップできていればOK

### 5. 定期的にフルバックアップする

ここではcronを使用する

```
sudo -u postgres crontab -e
```

ここに書き込む

```bash
0 3 * * * /usr/local/bin/wal-g.sh backup-push /var/lib/postgresql/12/main/ ; /usr/local/bin/wal-g.sh delete retain 7 --confirm
```

ここでは毎日深夜3時にフルバックアップと古い物を削除（7個残す）するようにした

***

## リストア

別マシンでバックアップ元と同じバージョンのPostgreSQLをインストールする

### 1. WAL-Gをインストールし設定ファイルをコピーする

バックアップ設定時と同じようにインストールしwal-g.shを/usr/local/binに配置する

### 2. クラスタの作成

クラスタを作成してデータディレクトリを空にする

```bash
sudo su - postgres
pg_createcluster 12 test
rm -rf /var/lib/postgresql/12/test/*
exit
```

### 3. 設定ファイルの編集

必要に応じて/etc/postgresql/12/test/postgresql.confの編集をする

### 4. 差分復元コマンドの設定

/etc/postgresql/12/main/conf.d/restore.confを作成し次のように書き込む

```bash
restore_command: '/usr/local/bin/wal-g.sh wal-fetch "%f" "%p"
```

### 5. リストアする

次のコマンドで最新のフルバックアップをリストアする

```bash
sudo -u postgres wal-g.sh backup-fetch /var/lib/postgresql/12/test/ LATEST
```

次のコマンドで最新の差分を復元しクラスタを動かす

```bash
sudo -u postgres touch /var/lib/postgresql/12/test/recovery.signal
sudo systemctl start postgresql@12-test
```

正常に復元できればrecovery.signalが削除される

※クラスタの削除は`sudo -u postgres  pg_dropcluster 12 test --stop`
