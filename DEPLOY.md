# DS Diary 部署教程

适用于本项目的三种部署方式：Vercel、GitHub Pages、Netlify。

---

## 零、部署前检查

项目根目录应包含：

```
index.html          package.json        vite.config.js
vercel.json         .gitignore          .nojekyll
public/config.json  public/logo.png     public/favicon.ico
src/                （完整源码）
```

跑一次 `deploy.bat` 会自动检查上述文件完整性、Node/Git 环境、安装依赖并构建。

本地验证构建：

```bash
npm install
npm run build      # 成功后会生成 dist/
npm run preview    # 本地预览 dist/
```

> ⚠️ 配置文件必须放在 `public/config.json`。放在项目根目录不会被打包进 `dist/`，线上会 404。

---

## 一、Vercel（推荐）

1. 把项目推到 GitHub。
2. 打开 <https://vercel.com/new>，导入该仓库。
3. 构建设置（通常会被自动识别）：

   | 项 | 值 |
   |---|---|
   | Framework Preset | Vite |
   | Build Command | `npm run build` |
   | Output Directory | `dist` |
   | Install Command | `npm install` |

4. 点击 **Deploy**，等待完成即可访问分配的域名。
5. 后续每次 `git push`，Vercel 会自动重新构建部署。

### 绑定自定义域名

在 Vercel 项目 → **Settings → Domains** 添加域名，然后到域名服务商处按提示配置 CNAME 记录。

---

## 二、GitHub Pages

1. 构建：`npm run build`
2. 将 `dist/` 内容推到 `gh-pages` 分支：

```bash
cd dist
git init
git add -A
git commit -m "deploy"
git push -f git@github.com:用户名/仓库名.git main:gh-pages
```

3. 仓库 → **Settings → Pages**，Source 选择 `gh-pages` 分支。
4. 项目已包含 `.nojekyll`，无需额外配置即可正确加载 `_` 开头的资源目录。

> `vite.config.js` 中已设置 `base: './'`，部署在 `https://用户名.github.io/仓库名/` 这类子路径下也能正常加载资源。

---

## 三、Netlify

1. 打开 <https://app.netlify.com/> → **Add new site → Import an existing project**。
2. 连接 Git 仓库，填写：

   | 项 | 值 |
   |---|---|
   | Build command | `npm run build` |
   | Publish directory | `dist` |

3. 点击 **Deploy site**。

或用 CLI：

```bash
npm install -g netlify-cli
npm run build
netlify deploy --prod --dir=dist
```

---

## 常见问题

| 现象 | 原因与处理 |
|---|---|
| 线上 `config.json` 404 | 配置文件不在 `public/` 目录；移到 `public/config.json` |
| 资源 404 / 白屏 | `base` 配置与实际部署路径不匹配，本项目用 `./` 相对路径即可 |
| `@变量 is undefined` | Less 每个文件独立编译，需要在该文件内 `@import './variables.less'` |
| 构建报 `terser not found` | Vite 5 中 terser 是可选依赖，本项目已改用 `minify: 'esbuild'`，无需安装 |
| 背景音乐不自动播放 | 浏览器自动播放策略限制；本项目在首屏点击的手势内启动播放，属正常设计 |
| 背景特效不动 | 系统开启了「减弱动效」，此时只渲染静态星链，属正常降级 |

---

## 部署后自检

- [ ] 首屏正常显示，背景粒子在动，点击可进入
- [ ] 进入后 Logo、打字机、导航、页脚正常
- [ ] 打开控制台无红色报错（浏览器扩展的 `chrome-extension://` 报错与本项目无关）
- [ ] `站点域名/config.json` 能返回 JSON
- [ ] 手机端打开正常，布局未错位
