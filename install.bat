@echo off
chcp 65001 >nul
echo 🦐 开始安装 内容生成多 Agent 系统 v4.0.2...
echo.

:: 检查 Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 错误：未找到 Node.js
    echo    请先安装 Node.js ^>= 18.0.0: https://nodejs.org
    exit /b 1
)

for /f "tokens=2 delims=v." %%i in ('node -v') do set NODE_VERSION=%%i
for /f "tokens=1 delims=." %%j in ("%NODE_VERSION%") do set NODE_MAJOR=%%j

if %NODE_MAJOR% LSS 18 (
    echo ❌ 错误：Node.js 版本过低 (当前：v%NODE_VERSION%)
    echo    请升级 Node.js ^>= 18.0.0
    exit /b 1
)

echo ✓ Node.js 版本：v%NODE_VERSION%
echo.

:: 设置 OpenClaw 目录 - 使用 workspace-main 而非硬编码路径
set OPENCLAW_DIR=%USERPROFILE%\.openclaw\workspace-main

:: 检查 OpenClaw 是否安装
if not exist "%OPENCLAW_DIR%" (
    echo ❌ 错误：未找到 OpenClaw 安装目录
    echo    请先安装 OpenClaw: https://docs.openclaw.ai
    echo    预期路径：%OPENCLAW_DIR%
    exit /b 1
)

echo ✓ OpenClaw 安装目录：%OPENCLAW_DIR%
echo.

:: 创建 skills 目录
set SKILLS_DIR=%OPENCLAW_DIR%\skills
if not exist "%SKILLS_DIR%" (
    echo 📁 创建 skills 目录...
    mkdir "%SKILLS_DIR%"
)

cd /d "%SKILLS_DIR%"

:: 检查是否已安装
if exist "content-creation-multi-agent" (
    echo ⚠️  检测到已安装的版本
    echo.
    set /p OVERWRITE="是否覆盖安装？(y/N): "
    if /i not "%OVERWRITE%"=="y" (
        echo ❌ 安装已取消
        exit /b 0
    )
    echo 🗑️  删除旧版本...
    rmdir /s /q "content-creation-multi-agent"
)

:: 克隆技能包
echo 📦 克隆技能包...
git clone https://github.com/jiebao360/content-creation-multi-agent.git
if %errorlevel% neq 0 (
    echo ❌ 克隆失败，请检查网络连接或 Git 是否安装
    exit /b 1
)

cd content-creation-multi-agent

:: 安装依赖
echo 📦 安装依赖包...
call npm install
if %errorlevel% neq 0 (
    echo ❌ 依赖安装失败
    exit /b 1
)

:: 创建必要的目录
echo 📁 创建配置目录...
if not exist "output" mkdir output
if not exist "logs" mkdir logs
if not exist "scripts" mkdir scripts
if not exist "config" mkdir config
if not exist "examples" mkdir examples

:: 创建 bot-configs 目录
if not exist "%OPENCLAW_DIR%\bot-configs" mkdir "%OPENCLAW_DIR%\bot-configs"

:: 创建配置文件
if not exist "config\agents.json" (
    echo ⚙️  创建 Agent 配置文件...
    (
        echo {
        echo   "version": "4.0.2",
        echo   "agents": {
        echo     "Note": {
        echo       "name": "第二大脑笔记虾",
        echo       "type": "knowledge-management",
        echo       "model": "doubao-pro",
        echo       "skills": ["web-search", "file-reading", "knowledge-management"]
        echo     },
        echo     "Content": {
        echo       "name": "内容创作",
        echo       "type": "article-writing",
        echo       "model": "doubao",
        echo       "skills": ["article-writer", "ai-daily-news"]
        echo     },
        echo     "Moments": {
        echo       "name": "朋友圈创作",
        echo       "type": "social-media",
        echo       "model": "doubao",
        echo       "skills": ["copywriting", "social-media"]
        echo     },
        echo     "Video Director": {
        echo       "name": "视频导演",
        echo       "type": "video-script",
        echo       "model": "doubao-pro",
        echo       "skills": ["video-script", "storyboard"]
        echo     },
        echo     "Image Generator": {
        echo       "name": "图片生成",
        echo       "type": "image-generation",
        echo       "model": "doubao-pro",
        echo       "skills": ["image-search", "doubao-prompt", "image-generation"]
        echo     },
        echo     "Seedance Director": {
        echo       "name": "Seedance 导演",
        echo       "type": "video-prompt",
        echo       "model": "doubao-pro",
        echo       "skills": ["seedance-prompt", "video-direction", "prompt-engineering"]
        echo     }
        echo   },
        echo   "auto_match_rules": {
        echo     "default": ["Note", "Content"],
        echo     "keywords": {
        echo       "内容 | 创作|Content": ["Note", "Content"],
        echo       "笔记 |Note| 知识": ["Note"],
        echo       "朋友圈|Moments|社交": ["Note", "Moments"],
        echo       "视频|Video|导演": ["Note", "Video Director", "Seedance Director"],
        echo       "图片|Image|设计": ["Note", "Image Generator"],
        echo       "自媒体 | 运营": ["Note", "Content", "Moments", "Image Generator"]
        echo     }
        echo   }
        echo }
    ) > config\agents.json
    echo ✓ 已创建 config\agents.json
)

echo.
echo ✅ 安装完成！
echo.
echo 📍 安装位置：%SKILLS_DIR%\content-creation-multi-agent
echo.
echo 🚀 下一步：
echo    1. 运行配置脚本:
echo       cd %SKILLS_DIR%\content-creation-multi-agent
echo       bash scripts\configure-bot.sh
echo.
echo    2. 重启 Gateway:
echo       openclaw gateway restart
echo.
echo    3. 在飞书机器人对话中测试
echo.
echo 📖 查看文档：type README.md
echo.
pause
