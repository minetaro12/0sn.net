---
title: "Bashのリダイレクトまとめ"
date: 2025-01-15T11:59:57+09:00
tags: ["linux","bash"]
comments: true
showToc: true
---

標準出力周りのリダイレクトの書き方を忘れることがあったのでメモ  
動作を試すために以下のGoのプログラムを使用しました。
```go
package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Fprintln(os.Stdout, "This is stdout")
	fmt.Fprintln(os.Stderr, "This is stderr")
}
```

## 標準出力をファイルに書き出す
```bash
$ ./stdtest > file もしくは ./stdtest 1> file
This is stderr
$ cat file
This is stdout
```

## 標準エラー出力をファイルに書き出す
```bash
$ ./stdtest 2> file
This is stdout
$ cat file
This is stderr
```
それぞれ`command 1> file1 2>file2`のように分けて書き出すこともできる。
## 標準出力とエラー出力両方をファイルに書き出す
```bash
$ ./stdtest &> file もしくは ./stdtest >& file
$ cat file
This is stdout
This is stderr
```

## 標準出力と標準エラー出力をマージする
```bash
$ ./stdtest > file 2>&1
$ cat file
This is stdout
This is stderr
```
逆だとうまく動かないので注意する。