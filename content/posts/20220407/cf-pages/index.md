---
title: "Cloudflare Pagesに移行しました"
date: "2022-04-07T18:44:58+09:00"
tags: ["cloudflare", "web"]
comments: true
showToc: false
---
Cloudflare Pages自体は前から知っていたのですが、ビルドの速度が非常に遅くあまり使っていませんでした。

しかし最近見たところ高速ビルドなるオプションがありました。

[Cloudflare Pages Fast Builds - Open Beta](https://community.cloudflare.com/t/cloudflare-pages-fast-builds-open-beta/359897)

試してみると今までデプロイに5分ほどかかっていたところ、なんと30秒ほど(このサイトの場合)でデプロイが完了しました。

表示速度的にはCloudflare Pagesの方が高速なためVercelから移行しました。

---

Hugoの場合デフォルトのまま使うとかなり古いバージョンが選択されるので、環境変数で指定するようにしました。

`HUGO_VERSION=0.96.0`

ビルドの構成は下のように設定しました。

ビルドコマンド: `TZ='Asia/Tokyo' hugo --gc --minify`  
ビルド出力ディレクトリ: `/public`