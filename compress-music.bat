@echo off
chcp 65001 >nul 2>&1
title 🎵 音乐文件压缩工具 - DS Diary

echo ============================================
echo   🎵 DS Diary - 音乐文件压缩工具
echo ============================================
echo.

:: 检查 ffmpeg 是否可用
where ffmpeg >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误: 未找到 ffmpeg
    echo.
    echo 请先安装 ffmpeg:
    echo   1. 访问 https://ffmpeg.org/download.html
    echo   2. 下载 Windows 版本并解压
    echo   3. 将 ffmpeg.exe 所在目录添加到系统 PATH 环境变量
    echo.
    echo 或者使用在线工具:
    echo   https://audio.online-convert.com/convert-to-mp3
    echo   https://convertio.co/flac-mp3/
    echo.
    pause
    exit /b 1
)

:: 设置路径
set "PROJECT_DIR=%~dp0"
set "MUSIC_DIR=%PROJECT_DIR%public\music"
set "INPUT_FILE=%MUSIC_DIR%\background.mp3"
set "OUTPUT_FILE=%MUSIC_DIR%\background-compressed.mp3"
set "BACKUP_FILE=%MUSIC_DIR%\background-backup.mp3"

:: 检查输入文件
if not exist "%INPUT_FILE%" (
    echo ❌ 错误: 找不到音乐文件 %INPUT_FILE%
    pause
    exit /b 1
)

:: 显示原始文件信息
echo 📁 原始文件: %INPUT_FILE%
for %%A in ("%INPUT_FILE%") do (
    set "SIZE_MB=%%~zA"
    set /a "SIZE_MB=!SIZE_MB! / 1048576"
    echo 📊 大小: !SIZE_MB! MB
)
echo.

:: 备份原始文件
echo 📦 备份原始文件...
copy "%INPUT_FILE%" "%BACKUP_FILE%" >nul 2>&1
echo ✅ 备份完成: %BACKUP_FILE%
echo.

:: 压缩选项
echo 请选择压缩质量:
echo   [1] 高质量 (192kbps) - 推荐用于音乐
echo   [2] 中等质量 (128kbps) - 平衡质量和大小
echo   [3] 低质量 (96kbps) - 最小文件大小
echo   [4] 自定义比特率
echo.
set /p CHOICE=请输入选项 (1-4):

if "%CHOICE%"=="1" set "BITRATE=192k"
if "%CHOICE%"=="2" set "BITRATE=128k"
if "%CHOICE%"=="3" set "BITRATE=96k"
if "%CHOICE%"=="4" (
    set /p BITRATE=请输入比特率 (例如: 128k, 192k, 320k):
)

echo.
echo 🔧 开始压缩...
echo    比特率: %BITRATE%
echo    输出: %OUTPUT_FILE%
echo.

:: 执行压缩
ffmpeg -y -i "%INPUT_FILE%" -codec:a libmp3lame -b:a "%BITRATE%" -ar 44100 -ac 2 "%OUTPUT_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ✅ 压缩成功!
    echo.

    :: 显示压缩结果
    for %%A in ("%INPUT_FILE%") do set "ORIGINAL_SIZE=%%~zA"
    for %%A in ("%OUTPUT_FILE%") do set "COMPRESSED_SIZE=%%~zA"

    set /a "ORIGINAL_MB=!ORIGINAL_SIZE! / 1048576"
    set /a "COMPRESSED_MB=!COMPRESSED_SIZE! / 1048576"
    set /a "SAVED=!ORIGINAL_SIZE! - !COMPRESSED_SIZE!"
    set /a "SAVED_PERCENT=!SAVED! * 100 / !ORIGINAL_SIZE!"

    echo 📊 压缩结果:
    echo    原始大小: !ORIGINAL_MB! MB
    echo    压缩后: !COMPRESSED_MB! MB
    echo    节省: !SAVED_PERCENT!%%
    echo.

    :: 替换原始文件
    choice /C YN /M "是否用压缩版本替换原始文件?"
    if errorlevel 2 (
        echo 📝 保留原始文件，压缩版本保存在: %OUTPUT_FILE%
    ) (
        copy "%OUTPUT_FILE%" "%INPUT_FILE%" >nul 2>&1
        del "%OUTPUT_FILE%" >nul 2>&1
        echo ✅ 已替换为压缩版本
    )
) else (
    echo.
    echo ❌ 压缩失败!
    echo    请检查 ffmpeg 是否正确安装
)

echo.
pause
