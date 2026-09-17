# DS Diary — 个人主页 1.0

> NOIR 暗黑极简个人主页 · Vue 3 + Vite + Less

一个带门禁首屏、星链粒子背景与音乐播放的个人主页。

---

## 亮点

- **背景特效体系** — 细栅格流动 + 青紫双光晕漂移 + 星链粒子（连线 / 鼠标牵引 / 呼吸闪烁）+ 扫描光带 + 暗角噪点
- **入场首屏** — 首屏自带同一套背景特效（加强档），整屏可点击；支持 Enter / Space 键盘进入
- **交互反馈** — 准星光标 + 丝带拖尾 + 环境光晕；点击时冲击环扩散、火花迸射，并打散背景粒子
- **音乐播放** — 全局音频单例，在首屏点击的用户手势内同步启动，不受浏览器自动播放策略拦截
- **集中配置** — 站点信息、首屏文案、导航、音乐、背景强度全部在 `public/config.json` 中调整
- **稳健降级** — 纯 Canvas 2D 实现，不依赖 WebGL；页面隐藏自动暂停渲染，尊重系统「减弱动效」设置

---

## 目录结构

```
DSHome-1.0/
├── index.html                  # 入口 HTML
├── vite.config.js              # Vite 配置（base: './'）
├── package.json
├── deploy.bat                  # 一键检查 + 构建 + Git 推送
├── public/
│   ├── config.json             # ⭐ 全站配置（唯一配置来源）
│   ├── logo.png                # 站点 Logo
│   ├── favicon.ico
│   └── music/background.mp3    # 背景音乐
└── src/
    ├── main.js
    ├── App.vue                 # 首屏门禁 → 主内容挂载
    ├── assets/styles/
    │   ├── variables.less      # 设计变量（配色 / 字号 / 间距 / 层级）
    │   ├── global.less         # 全局重置
    │   ├── animations.less     # 动画库
    │   └── responsive.less     # 响应式
    ├── components/
    │   ├── BackgroundFX.vue    # ⭐ 背景特效总成（栅格 / 光晕 / 星链粒子 / 扫描带）
    │   ├── EntryScreen.vue     # ⭐ 入场首屏（自带背景特效 + 冲击环）
    │   ├── ClickFX.vue         # ⭐ 全局点击特效（冲击环 + 火花 + 粒子爆发）
    │   ├── CustomCursor.vue    # 准星光标 + 丝带拖尾 + 环境光晕
    │   ├── HeroSection.vue     # 主视觉（Logo + 打字机）
    │   ├── Navigation.vue      # 站点导航
    │   ├── Footer.vue          # 页脚
    │   └── MusicPlayer.vue     # 音乐播放器
    └── composables/
        ├── useConfig.js        # 配置加载与合并
        ├── useEntry.js         # 入场状态
        ├── useAudio.js         # 全局音频单例
        └── useFx.js            # 特效总线（点击 → 背景粒子爆发）
```

---

## 快速开始

```bash
npm install       # 安装依赖
npm run dev       # 本地开发（http://localhost:3000）
npm run build     # 生产构建（输出 dist/）
npm run preview   # 预览构建产物
```

---

## 配置说明

改配置请编辑 **`public/config.json`**（放在项目根目录不会被打包进 `dist/`，会导致线上 404）。

| 配置段 | 作用 |
|---|---|
| `site` | 标题、描述、favicon |
| `background` | `enabled` 总开关 · `clickFx` 点击特效 · `entryIntensity` 首屏背景强度 |
| `entry` | 首屏开关、Logo、主标题、副标题、提示文案、`sessionOnce`、`musicOnEnter` |
| `hero` | 主视觉 Logo、打字机文案、签名、滚动提示 |
| `navigation` | 导航项（名称 / 链接 / 图标 / 打开方式） |
| `music` | 音乐地址、音量、循环、是否随首屏点击播放 |
| `cursor` | 自定义光标开关 |
| `footer` | 页脚文案与展示项 |

---

## 部署

**Vercel** — 导入仓库，框架自动识别为 Vite，构建命令 `npm run build`，输出目录 `dist`。

**GitHub Pages** — 构建后把 `dist/` 内容推到 `gh-pages` 分支（项目已含 `.nojekyll`）。

**命令行推送**：

```bash
git add -A
git commit -m "DS Diary 1.0"
git push
```

---

## 技术栈

| 技术 | 用途 |
|---|---|
| Vue 3.4 | 组件化框架 |
| Vite 5 | 构建工具（esbuild 压缩） |
| Less 4 | 样式预处理 |
| Canvas 2D | 星链粒子 / 丝带拖尾 |
| Web Audio API | 光标点击音效 |

---

## 说明

- `vite.config.js` 中 `base: './'` 使用相对路径，可部署到任意子路径。
- 背景与光标特效在移动端自动降级（减少粒子数量、隐藏扫描光带与自定义光标）。
