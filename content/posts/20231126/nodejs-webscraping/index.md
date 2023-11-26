---
title: "Node.jsでウェブスクレイピング"
date: 2023-11-26T14:30:45+09:00
tags: ["nodejs","javascript", "web"]
comments: true
showToc: true
---
[jsdom](https://github.com/jsdom/jsdom)を使ってNode.jsでウェブスクレイピングをやってみる。

## jsdomの導入
```
$ pnpm add jsdom
```

## 使い方
```javascript
import { JSDOM } from "jsdom"

const dom = new JSDOM(`<!DOCTYPE html><p>Hello world</p>`)
console.log(dom.window.document.querySelector("p").textContent) // Hello world
```
ブラウザと同じようにDOMの操作ができるようになる。

### このブログのトップページから記事名を取得する例
```javascript
import { JSDOM } from "jsdom"

const main = async () => {
  const dom = await JSDOM.fromURL("https://0sn.net/")
  dom.window.document.querySelectorAll(".list-posts-item-title").forEach((element) => {
    console.log(element.textContent)
  })
}

main()
```

```
$ node index.js
GRUB2でext4が認識されない場合の対処
Ubuntuで新しいバージョンのカーネルを使う
Xfce4でWindowsキーを使ってメニューを開きたい
SoftEther VPNのサーバー証明書をLegoで取得する
Arch LinuxでAvahiを使う
Manjaroを手動インストールする
systemd-timerを使ってみる
LineageOS20のビルド (Essential Phone)
WindowsのデュアルブートでOS選択画面を従来のものに戻す
WSLにArch Linuxをインストールする
```