---
title: "Cloudflare PagesでHugoのGitInfoが使えない問題"
date: 2024-09-17T21:55:46+09:00
tags: ["cloudflare","hugo", "git"]
comments: true
showToc: false
---
Cloudflare Pagesではクローン時に`git clone --depth 1 <URL>`のような動作（シャロークローン）をしているようで、Git履歴を使った記事ごとの最終更新日が取得できなかった。  
`git fetch --unshallow`を実行すると履歴を取得することができるので、ビルドコマンドに付け加えて解決した。

[該当のコミット](https://github.com/minetaro12/0sn.net/commit/f7cc88c2e387778a56cc97e8782b431510bc2107)

## 参考
- https://gohugo.io/methods/page/gitinfo/#hosting-considerations
- https://blog.kotet.jp/2023/10/gohugo-gitinfo/
