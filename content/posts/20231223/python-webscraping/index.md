---
title: "PythonでWebスクレイピング"
date: 2023-12-23T22:35:04+09:00
tags: ["python","web"]
comments: true
showToc: true
---
[Beautiful Soup](https://www.crummy.com/software/BeautifulSoup/bs4/doc/)を使ってWebスクレイピングをやってみる。

## 導入
リクエストを飛ばすため`requests`も同時に導入する。
```bash
$ pip install bs4 requests
```

## 使い方
```python
#!/usr/bin/env python

import bs4


def main():
    soup = bs4.BeautifulSoup(
        "<!DOCTYPE html><p>Hello world</p>", "html.parser")
    print(soup.select_one("p").get_text()) # Hello world


if __name__ == "__main__":
    main()

```

### このブログのトップページから記事名を取得する例
```python
#!/usr/bin/env python

import bs4
import requests


def main():
    res = requests.get("https://0sn.net/")
    soup = bs4.BeautifulSoup(res.text, "html.parser")
    for element in soup.select(".list-posts-item-title"):
        print(element.get_text())


if __name__ == "__main__":
    main()

```

```
$ python3 main.py
LinuxでGRETAP
Node.jsでウェブスクレイピング
GRUB2でext4が認識されない場合の対処
Ubuntuで新しいバージョンのカーネルを使う
Xfce4でWindowsキーを使ってメニューを開きたい
SoftEther VPNのサーバー証明書をLegoで取得する
Arch LinuxでAvahiを使う
Manjaroを手動インストールする
systemd-timerを使ってみる
LineageOS20のビルド (Essential Phone)
```

### 取得したテキストに余計な空白が入る場合
サイトによっては取得したテキストに余計な空白が入る場合があるので、`get_text`で以下のようにして除去できる。
```python
element.get_text(strip=True)
```