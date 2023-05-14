---
title: "WindowsのデュアルブートでOS選択画面を従来のものに戻す"
date: 2023-05-14T15:46:23+09:00
tags: ["windows","bootloader"]
comments: true
showToc: false
---
新しいタイプの青いOS選択画面はWindowsが読み込まれてから表示され遅いので、下のコマンドで従来の黒いOS選択画面に戻す。  
管理者権限で実行する。
```cmd
bcdedit /set '{current}' bootmenupolicy legacy
```

元に戻す場合は以下のコマンドを実行する。  
```cmd
bcdedit /set '{current}' bootmenupolicy standard
```