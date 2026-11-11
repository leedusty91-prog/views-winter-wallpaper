#!/bin/bash
# 用法：./install.sh path/to/wallpaper.mp4 [still.jpg]
set -e
D="$HOME/LiveWallpaper"; mkdir -p "$D"
cp "$1" "$D/wallpaper.mp4"
[ -n "$2" ] && cp "$2" "$D/still_2560.jpg" && cp "$2" "$D/still_1920.jpg"
swiftc -O "$(dirname "$0")/main.swift" -o "$D/LiveWallpaper"
P="$HOME/Library/LaunchAgents/com.example.livewallpaper.plist"
sed "s#__HOME__#$HOME#" "$(dirname "$0")/com.example.livewallpaper.plist" > "$P"
launchctl unload "$P" 2>/dev/null || true
launchctl load "$P"
echo "已安装，壁纸程序已启动。"
