@echo off
chcp 65001 >nul
title DS Diary 一键部署工具 1.0

echo ╔════════════════════════════════════════════════════════════╗
echo ║       DS Diary 个人主页 部署工具 1.0                     ║
echo ║       NOIR 暗黑极简 | Vue 3 + Vite + Less                ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

:: 检查文件完整性
echo [1/6] 检查文件完整性...

set MISSING=0

:: 根目录文件（注意：config.json 已移至 public/ 目录）
if not exist "public\config.json" (
    echo   ❌ 缺少 public\config.json
    set /a MISSING+=1
)
if not exist "package.json" (
    echo   ❌ 缺少 package.json
    set /a MISSING+=1
)
if not exist "vite.config.js" (
    echo   ❌ 缺少 vite.config.js
    set /a MISSING+=1
)
if not exist "index.html" (
    echo   ❌ 缺少 index.html
    set /a MISSING+=1
)
if not exist "vercel.json" (
    echo   ❌ 缺少 vercel.json
    set /a MISSING+=1
)
if not exist ".gitignore" (
    echo   ❌ 缺少 .gitignore
    set /a MISSING+=1
)
if not exist ".nojekyll" (
    echo   ❌ 缺少 .nojekyll
    set /a MISSING+=1
)

:: public 目录
if not exist "public\favicon.ico" (
    echo   ❌ 缺少 public\favicon.ico
    set /a MISSING+=1
)
if not exist "public\logo.png" (
    echo   ❌ 缺少 public\logo.png
    set /a MISSING+=1
)
if not exist "public\music\background.mp3" (
    echo   ⚠️  缺少 public\music\background.mp3（可选）
)

:: src 目录
if not exist "src\main.js" (
    echo   ❌ 缺少 src\main.js
    set /a MISSING+=1
)
if not exist "src\App.vue" (
    echo   ❌ 缺少 src\App.vue
    set /a MISSING+=1
)
if not exist "src\composables\useConfig.js" (
    echo   ❌ 缺少 src\composables\useConfig.js
    set /a MISSING+=1
)
if not exist "src\composables\useEntry.js" (
    echo   ❌ 缺少 src\composables\useEntry.js
    set /a MISSING+=1
)
if not exist "src\composables\useAudio.js" (
    echo   ❌ 缺少 src\composables\useAudio.js
    set /a MISSING+=1
)
if not exist "src\composables\useFx.js" (
    echo   ❌ 缺少 src\composables\useFx.js
    set /a MISSING+=1
)
if not exist "src\components\EntryScreen.vue" (
    echo   ❌ 缺少 src\components\EntryScreen.vue
    set /a MISSING+=1
)
if not exist "src\components\BackgroundFX.vue" (
    echo   ❌ 缺少 src\components\BackgroundFX.vue
    set /a MISSING+=1
)
if not exist "src\components\ClickFX.vue" (
    echo   ❌ 缺少 src\components\ClickFX.vue
    set /a MISSING+=1
)
if not exist "src\components\HeroSection.vue" (
    echo   ❌ 缺少 src\components\HeroSection.vue
    set /a MISSING+=1
)
if not exist "src\components\Navigation.vue" (
    echo   ❌ 缺少 src\components\Navigation.vue
    set /a MISSING+=1
)
if not exist "src\components\MusicPlayer.vue" (
    echo   ❌ 缺少 src\components\MusicPlayer.vue
    set /a MISSING+=1
)
if not exist "src\components\CustomCursor.vue" (
    echo   ❌ 缺少 src\components\CustomCursor.vue
    set /a MISSING+=1
)
if not exist "src\components\Footer.vue" (
    echo   ❌ 缺少 src\components\Footer.vue
    set /a MISSING+=1
)
if not exist "src\assets\styles\variables.less" (
    echo   ❌ 缺少 src\assets\styles\variables.less
    set /a MISSING+=1
)
if not exist "src\assets\styles\global.less" (
    echo   ❌ 缺少 src\assets\styles\global.less
    set /a MISSING+=1
)
if not exist "src\assets\styles\animations.less" (
    echo   ❌ 缺少 src\assets\styles\animations.less
    set /a MISSING+=1
)
if not exist "src\assets\styles\responsive.less" (
    echo   ❌ 缺少 src\assets\styles\responsive.less
    set /a MISSING+=1
)

if %MISSING% GTR 0 (
    echo.
    echo   ⚠️  发现 %MISSING% 个文件缺失！部署可能会失败。
    echo.
    set /p CONTINUE="是否继续？(Y/N): "
    if /i not "%CONTINUE%"=="Y" exit /b 1
) else (
    echo   ✅ 所有必需文件检查通过 (27/27)
)

echo.

:: 检查 Node.js
echo [2/6] 检查 Node.js 环境...
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   ❌ 未检测到 Node.js，请先安装：https://nodejs.org/
    pause
    exit /b 1
)
node -v
echo   ✅ Node.js 已安装

echo.

:: 检查 Git
echo [3/6] 检查 Git 环境...
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   ❌ 未检测到 Git，请先安装：https://git-scm.com/
    pause
    exit /b 1
)
git --version
echo   ✅ Git 已安装

echo.

:: 安装依赖
echo [4/6] 安装项目依赖...
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo   ❌ npm install 失败！
    echo   可能的解决方案：
    echo   1. 检查网络连接
    echo   2. 尝试切换镜像：npm config set registry https://registry.npmmirror.com
    pause
    exit /b 1
)
echo   ✅ 依赖安装完成

echo.

:: 构建项目
echo [5/6] 构建生产版本...
call npm run build
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo   ❌ 构建失败！请检查上方错误信息。
    echo   常见问题：
    echo   - LESS 变量未定义 → 检查 @import 语句
    echo   - ESM 导出错误 → 使用 export default 而非 module.exports
    echo   - Top-level await → 重构为异步函数
    pause
    exit /b 1
)
echo   ✅ 构建成功！输出目录: dist/

echo.

:: Git 初始化和推送
echo [6/6] 初始化 Git 并准备推送...
if not exist ".git" (
    git init
    git add .
    git commit -m "Initial commit: DSHome-Pro NOIR v8.0"
    echo   ✅ Git 仓库初始化完成
) else (
    git add -A
    git commit -m "DS Diary 1.0" --allow-empty
    echo   ✅ Git 更新完成
)

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║                      ✅ 准备就绪！                       ║
echo ╠════════════════════════════════════════════════════════════╣
echo ║                                                        ║
echo ║  下一步操作：                                           ║
echo ║                                                        ║
echo ║  1. 在 GitHub 创建新仓库（如果还没有）                   ║
echo ║     访问: https://github.com/new                       ║
echo ║     仓库名建议: DSHome                                 ║
echo ║                                                        ║
echo ║  2. 添加远程仓库并推送：                                ║
echo ║     git remote add origin https://github.com/用户名/DSHome.git ║
echo ║     git push -u origin main                            ║
echo ║                                                        ║
echo ║  3. 在 Vercel 部署：                                    ║
echo ║     访问: https://vercel.com/new                       ║
echo ║     导入你的 GitHub 仓库                               ║
echo ║     点击 Deploy                                       ║
echo ║                                                        ║
echo ║  详细教程请查看 DEPLOY.md                              ║
echo ║                                                        ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

pause
