+++
title = "Hugoでリンクを新しいタブで開くようにする"
date = "2022-02-22T09:47:23+09:00"
author = "minetaro12"
authorTwitter = "" #do not include @
cover = ""
tags = ["web", "hugo"]
keywords = ["", ""]
description = " "
showFullContent = false
readingTime = false
comments = true
toc = false
archives = ["2022", "2022-02"]
+++
次のように書くとリンクになりますが、デフォルトでは新しいタブでは開かずにそのまま飛びます。

```
[0sn.net](https://0sn.net/)
```

記事内でリンクを新しいタブで開いて欲しいときは、`layouts/_default/_markup/render-link.html`を作成し次の内容を書き込みます。

```html
<a href="{{ .Destination | safeURL }}"{{ with .Title}} title="{{ . }}"{{ end }}{{ if strings.HasPrefix .Destination "http" }} target="_blank"{{ end }}>{{ .Text }}</a>
```

---
参考にしたサイト

[Hugo 0.60 以降で「リンクを新しいタブで開く」方法](https://mobiusone.org/posts/open-link-in-new-tab-with-goldmark/)