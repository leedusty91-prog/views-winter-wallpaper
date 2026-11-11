# Views · Winter — 动态壁纸

Drake《Views》专辑封面的冬季版动态壁纸：塔顶积雪，窗外下雪，雪花落到玻璃上慢慢化开，闪电照亮整座塔。30 秒无缝循环，30fps。

![闪电那一刻](preview/hero_lightning.jpg)

## 怎么做的

- **底图**：积雪的塔是一张 AI 生成的底图（`render/assets/plate_2000.jpg`），参照原封面的构图。
- **其余全部是代码**：飘雪、玻璃上的水汽和水滴折射、落在玻璃上的雪花（落下、背光描边、融化）、底部积雪线、四道程序生成的闪电，以及闪电对塔的打光，全都写在 WebGL2 着色器里（都在 `render/template.html` 里，主合成着色器是其中的 `finFS`）。
- 闪电分别在 3.0s、9.5s（主闪电）、17.0s 和 23.5s 落下。

## 目录

| 路径 | 内容 |
| --- | --- |
| `render/` | 渲染页面、着色器、逐帧导出和编码脚本 |
| `macos/` | Mac 上的动态壁纸播放程序（Swift，AVPlayer 循环播放，放在桌面图标下面） |
| `windows/` | 用 Lively Wallpaper 在 Windows 上设置的方法 |
| `preview/` | 预览图 |

## 渲染

需要 Node、Python 3、Chrome 和 ffmpeg。

```bash
cd render
npm install
python3 build.py                     # 把底图打包进 views-storm.html，可以直接用浏览器打开看实时效果
node capture.js 1920 1080 30 m1920.mp4    # 逐帧导出 1080p 母版
node capture.js 2560 1664 30 m2560.mp4    # 逐帧导出 Mac 2560×1664 母版
./encode.sh                          # 压成最终的 H.264 / HEVC 文件，放到 render/out/
```

`capture.js` 默认用 `/usr/bin/google-chrome`，换成你本机 Chrome 的路径即可。

## Mac 安装

```bash
cd macos
./install.sh ../render/out/views-storm-2560x1664-hevc.mp4 ../preview/first_frame.jpg
```

播放程序做了几件事：窗口放在桌面层上面一层、桌面图标下面；视频底下垫一张同画面的静态图，系统壁纸也设成同一帧，这样切换窗口时不会闪黑；屏幕没真的变化就不重建窗口。

## 说明

这是粉丝向的个人作品，《Views》封面版权归原作者所有。
