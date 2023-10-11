---
title: "Xfce4でWindowsキーを使ってメニューを開きたい"
date: 2023-10-09T21:15:35+09:00
tags: ["linux","xfce4"]
comments: true
showToc: false
---
ManjaroのXfce4の場合デフォルトで`Alt`+`F1`でメニューが開くようになっているが、設定からWindowsキー(Superキー)に割り当てると`Win`+`L`等の組み合わせが効かなくなるのでその対処法  
起動時に以下のコマンドを実行するようにする(xcapeで左Windowsキーに左Alt+F1を割り当てる)
```
xcape -e "Super_L=Alt_L|F1"
```
