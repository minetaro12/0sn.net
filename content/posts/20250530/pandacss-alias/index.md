---
title: "Panda CSSをエイリアスで使う"
date: 2025-05-30T14:04:56Z
tags: ["panda css","react", "nodejs"]
comments: true
showToc: false
---
`styled-system`を相対パスでインポートして使っていたが、ファイルが深くなるとわかりにくくなるのでエイリアスを使ってインポートするメモ  

https://panda-css.com/docs/installation/vite の手順でインストールしている前提です。

`tsconfig.json`に以下の設定を追加
```json
{
  "compilerOptions": {
    "paths": {
      "@styled-system/*": ["./styled-system/*"]
    }
  },
  "include": ["src", "styled-system"] //これを忘れると補完が効かないので注意
}
```

`vite.config.ts`には以下のように設定を追加する
```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'node:path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@styled-system': resolve(__dirname, 'styled-system'),
    },
  },
})
```
---
これでtsx内で以下のようにインポートできる
```tsx
import { css } from '@styled-system/css'

function App() {
  return (
    <>
      <h1 className={css({ fontSize: 'xl', fontWeight: 'bold' })}>
        Welcome to My App
      </h1>
    </>
  )
}

export default App
```
