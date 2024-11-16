---
title: "PythonでWebスクレイピング（Selenium）"
date: 2024-11-15T21:47:52+09:00
tags: ["python","selenium", "web"]
comments: true
showToc: true
---
[以前の記事](/posts/20231223/python-webscraping/)ではBeautiful Soupを使ったが、JavaScriptでレンダリングするページやログインが必要な画面のスクレイピングができないので[Selenium](https://www.selenium.dev/ja/)を試してみる。  
Arch Linuxで動作確認を行いました。

## 導入
```bash
$ pip install selenium
```
利用するブラウザは実行時に自動的にダウンロードされた。

## 基本的な使い方
この例ではChromeを使い`https://example.com/`を開いてスクリーンショットを取得して終了する。
```python
#!/usr/bin/env python

from selenium import webdriver

def main():
    # Firefoxを使いたい場合はFirefox()にする
    driver = webdriver.Chrome()

    driver.get("https://example.com/")
    driver.save_screenshot("screenshot.png")
    driver.quit()

if __name__ == "__main__":
    main()
```

### このブログのトップページから記事名を取得する例
要素を探す場合は`selenium.webdriver.common.by`から`By`をインポートする必要がある。
```python
#!/usr/bin/env python

from selenium import webdriver
from selenium.webdriver.common.by import By

def main():
    driver = webdriver.Chrome()

    driver.get("https://0sn.net/")
    elements = driver.find_elements(By.CSS_SELECTOR, ".list-posts-item-title")

    for element in elements:
        print(element.text)

    driver.quit()

if __name__ == "__main__":
    main()
```

```bash
$ python3 main.py
IPSec MSCHAPv2で接続できるstrongSwanを構築
Android12以降の端末からstrongSwanに接続
Cloudflare PagesでHugoのGitInfoが使えない問題
Caddyとlogrotateの併用について
Caddyでnginxの444のように何も返さない設定
Arch Linuxのlibvirtで仮想マシンの電源をホストと連動させる
Btrfsを使ってみる
LVMを使ってみる
Linuxでファイル暗号化
LXCを試してみる
```
### フォームにテキストを入力する例
ここではGoogle検索で`selenium`と入力しエンターを入力する。
```python
#!/usr/bin/env python

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def main():
    driver = webdriver.Chrome()
    driver.get("https://google.com")

    element = driver.find_element(By.CSS_SELECTOR, 'textarea[title="検索"]')
    # seleniumと入力
    element.send_keys("selenium")
    # Enterキーを押下
    element.send_keys(Keys.RETURN)
    
    driver.quit()

if __name__ == "__main__":
    main()
```

### このブログのサイドメニューボタンをクリックする例
```python
#!/usr/bin/env python

from selenium import webdriver
from selenium.webdriver.common.by import By

def main():
    driver = webdriver.Chrome()

    driver.get("https://0sn.net/")
    # ここでクリック
    driver.find_element(By.CSS_SELECTOR, "#menu-button").click()
    driver.save_screenshot("screenshot.png")
    driver.quit()

if __name__ == "__main__":
    main()
```

### 入力・クリック可能になるまで待つ例
`WebDriverWait`を利用すると要素が入力やクリックができるようになるまで待機してくれる。  
例としてこのブログの検索ページを使ってみる。  
この例では`#search-input`がクリック可能になったら`python`と入力して検索結果を取得する。
```python
#!/usr/bin/env python

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

def main():
    driver = webdriver.Chrome()
    driver.get("https://0sn.net/search/")

    # タイムアウトを10秒に設定する
    wait = WebDriverWait(driver, 10)

    # 検索ボックスが入力できるようになるまで待つ
    searchBox = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "#search-input")))

    # 検索ボックスに"python"と入力する
    searchBox.send_keys("python")

    # 検索結果を取得
    elements = driver.find_elements(By.CSS_SELECTOR, "#search-result > div > a")
    for element in elements:
        print(element.text)
    
    driver.quit()

if __name__ == "__main__":
    main()
```

`element_to_be_clickable`以外にも条件がたくさんあるので以下の公式ページを参照。  
https://www.selenium.dev/selenium/docs/api/py/webdriver_support/selenium.webdriver.support.expected_conditions.html
