---
title: "i3wm導入のメモ"
date: "2022-11-05T14:20:24+09:00"
tags: ["linux", "i3", "arch-linux"]
comments: true
showToc: true
---
Arch Linuxへのi3wmの導入で色々とハマった箇所があったのでメモ。

## インストール

`yay -S i3`でi3のパッケージグループをインストールする。(`yay -S i3-gaps`でもOK)  
`lightdm`等を使って起動する。

## 設定

https://github.com/minetaro12/dotfiles  
自分はステータスバーに[polybar](https://github.com/polybar/polybar)、ランチャーに[rofi](https://github.com/davatorium/rofi)を使いました。

---

## 設定でハマった箇所

### 通知を表示させる

`yay -S xfce4-notifyd`で`xfce4-notifyd`をインストール。  
以下の設定で起動する。

- `exec --no-startup-id /usr/lib/xfce4/notifyd/xfce4-notifyd`

### polkitのパスワード入力画面が表示されない

`yay -S polkit-gnome`で`polkit-gnome`をインストール。  
以下の設定で起動する。

- `exec --no-startup-id /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1`

### DPIの設定

`~/.Xresources`に以下の記述を追加する。  
`Xft.dpi: 120`

### カーソルの変更

`~/.icons`にカーソルテーマを展開(自分は[ここ](https://www.pling.com/browse?cat=107)で探した)  
`~/.Xresources`に以下の記述を追加する。

- `Xcursor.theme: <カーソルテーマ名>`

`~/.config/gtk-3.0/settings.ini`の`[Settings]`にも以下の記述を追加。

- `gtk-cursor-theme-name=<カーソルテーマ>`

### picomでぼかしが効かない

`picom`は以下のようにして起動する。  
~~exec --no-startup-id picom -b --experimental-backends~~

`exec --no-startup-id picom -b`

`~/.config/picom.conf`では以下のように設定する。

```picom.conf
blur-method = "dual_kawase"
backend = "glx" #これをしないと激重になる
```

※2022/11/17追記  
v10で`--experimental-backends`がデフォルトで有効になった模様  
> [https://github.com/yshui/picom/releases/tag/v10](https://github.com/yshui/picom/releases/tag/v10)

### フローティングモードで起動させる

mpvをフローティングモードで起動するようにする場合は以下のように設定する.

- `for_window [class="mpv"] floating enable`

ウィンドウのクラス名は`xprop | grep WM_CLASS`で調べることができる。  
`WM_CLASS(STRING) = "pavucontrol", "Pavucontrol"`のように２つ出てくる場合は、両方試してみて動く方を使う。  
サイズを指定したい場合は以下の設定も追加する。

- `for_window [class="mpv"] resize set 1280 720`

### 指定したワークスペースで起動させる

discordをワークスペース3で起動させたい場合は以下のように設定する。

- `assign [class="discord"] workspace 3`

### すべてのワークスペースでフローティングウィンドウを表示させる

mpvで動画を再生してる時にすべてのワークスペースで表示してほしかったりするので以下のように設定する。

- `for_window [class="mpv"] sticky enable`

### ウィンドウの間に隙間を作る

`i3-gaps`を使っている必要があります。

```
gaps top 5
gaps bottom 5
gaps right 5
gaps left 5
gaps inner 5
```

### Thunarの右クリックからAlacrittyを開けない

編集→アクションの設定で`alacritty --working-directory %f`を実行するように設定する

### ThunarでVimを開いときに開いときにAlacrittyが開かない

`cp /usr/share/applications/vim.desktop ~/.local/share/applications/vim.desktop`でVimのデスクトップエントリをコピー。  
`~/.local/share/applications/vim.desktop`を編集し以下のように変更する。

```vim.desktop
Exec=alacritty -e vim %F
Terminal=false
```