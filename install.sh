#!/bin/bash

# 🦐 内容生成多 Agent 系统 - 安装脚本 v4.0.2
# 修复 Windows 路径问题，统一使用 workspace-main 目录

set -e

echo "🦐 开始安装 内容生成多 Agent 系统 v4.0.2..."
echo ""

# 检测操作系统
OS="$(uname -s)"
case "$OS" in
  Darwin)
    echo "✓ 检测到 macOS 系统"
    OPENCLAW_DIR="$HOME/.openclaw/workspace-main"
    ;;
  Linux)
    echo "✓ 检测到 Linux 系统"
    OPENCLAW_DIR="$HOME/.openclaw/workspace-main"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    echo "✓ 检测到 Windows 系统"
    OPENCLAW_DIR="$HOME/.openclaw/workspace-main"
    ;;
  *)
    echo "❌ 不支持的操作系统：$OS"
    exit 1
    ;;
esac

# 检查 OpenClaw 是否安装
if [ ! -d "$OPENCLAW_DIR" ]; then
  echo "❌ 错误：未找到 OpenClaw 安装目录"
  echo "   请先安装 OpenClaw: https://docs.openclaw.ai"
  echo "   预期路径：$OPENCLAW_DIR"
  exit 1
fi

echo "✓ OpenClaw 安装目录：$OPENCLAW_DIR"
echo ""

# 创建 skills 目录
SKILLS_DIR="$OPENCLAW_DIR/skills"
if [ ! -d "$SKILLS_DIR" ]; then
  echo "📁 创建 skills 目录..."
  mkdir -p "$SKILLS_DIR"
fi

# 进入 skills 目录
cd "$SKILLS_DIR"

# 检查是否已安装
if [ -d "content-creation-multi-agent" ]; then
  echo "⚠️  检测到已安装的版本"
  echo ""
  read -p "是否覆盖安装？(y/N): " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 安装已取消"
    exit 0
  fi
  echo "🗑️  删除旧版本..."
  rm -rf "content-creation-multi-agent"
fi

# 克隆技能包
echo "📦 克隆技能包..."
git clone https://github.com/jiebao360/content-creation-multi-agent.git
cd content-creation-multi-agent

# 检查 Node.js
if ! command -v node &> /dev/null; then
  echo "❌ 错误：未找到 Node.js"
  echo "   请先安装 Node.js >= 18.0.0: https://nodejs.org"
  exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  echo "❌ 错误：Node.js 版本过低 (当前：v$NODE_VERSION)"
  echo "   请升级 Node.js >= 18.0.0"
  exit 1
fi

echo "✓ Node.js 版本：$(node -v)"
echo ""

# 安装依赖
echo "📦 安装依赖包..."
npm install

# 创建必要的目录
echo "📁 创建配置目录..."
mkdir -p "$OPENCLAW_DIR/bot-configs"
mkdir -p output logs scripts config examples

# 创建配置文件
if [ ! -f "config/agents.json" ]; then
  echo "⚙️  创建 Agent 配置文件..."
  cat > config/agents.json << 'EOF'
{
  "version": "4.0.2",
  "agents": {
    "Note": {
      "name": "第二大脑笔记虾",
      "type": "knowledge-management",
      "model": "doubao-pro",
      "skills": ["web-search", "file-reading", "knowledge-management"]
    },
    "Content": {
      "name": "内容创作",
      "type": "article-writing",
      "model": "doubao",
      "skills": ["article-writer", "ai-daily-news"]
    },
    "Moments": {
      "name": "朋友圈创作",
      "type": "social-media",
      "model": "doubao",
      "skills": ["copywriting", "social-media"]
    },
    "Video Director": {
      "name": "视频导演",
      "type": "video-script",
      "model": "doubao-pro",
      "skills": ["video-script", "storyboard"]
    },
    "Image Generator": {
      "name": "图片生成",
      "type": "image-generation",
      "model": "doubao-pro",
      "skills": ["image-search", "doubao-prompt", "image-generation"]
    },
    "Seedance Director": {
      "name": "Seedance 导演",
      "type": "video-prompt",
      "model": "doubao-pro",
      "skills": ["seedance-prompt", "video-direction", "prompt-engineering"]
    }
  },
  "auto_match_rules": {
    "default": ["Note", "Content"],
    "keywords": {
      "内容|创作|Content": ["Note", "Content"],
      "笔记|Note|知识": ["Note"],
      "朋友圈|Moments|社交": ["Note", "Moments"],
      "视频|Video|导演": ["Note", "Video Director", "Seedance Director"],
      "图片|Image|设计": ["Note", "Image Generator"],
      "自媒体 | 运营": ["Note", "Content", "Moments", "Image Generator"]
    }
  }
}
EOF
  echo "✓ 已创建 config/agents.json"
fi

# 创建配置脚本
if [ ! -f "scripts/configure-bot.sh" ]; then
  echo "⚙️  创建配置脚本..."
  cat > scripts/configure-bot.sh << 'EOFSCRIPT'
#!/bin/bash

# 配置飞书机器人脚本

echo "🤖 配置飞书机器人"
echo ""

# 默认值
DEFAULT_BOT_NAME="内容创作"
DEFAULT_MODEL="doubao"

# 输入机器人名称
read -p "请输入飞书机器人名称（默认：$DEFAULT_BOT_NAME）: " BOT_NAME
BOT_NAME=${BOT_NAME:-$DEFAULT_BOT_NAME}
echo "✓ 机器人名称：$BOT_NAME"
echo ""

# 输入 App ID 和 App Secret
read -p "App ID（必填）: " APP_ID
read -p "App Secret（必填）: " APP_SECRET

if [ -z "$APP_ID" ] || [ -z "$APP_SECRET" ]; then
  echo "❌ 错误：App ID 和 App Secret 不能为空"
  exit 1
fi
echo "✓ 飞书应用凭证已配置"
echo ""

# 输入大模型名称
echo "配置大模型名称"
echo "提示：可以指定已经配置好的模型，也可以为空自动配置默认大模型"
read -p "大模型名称（默认：$DEFAULT_MODEL）: " MODEL
MODEL=${MODEL:-$DEFAULT_MODEL}
echo "✓ 大模型名称：$MODEL"
echo ""

# 选择 Agent
echo "请选择要创建的 Agent（输入序号，多个用逗号分隔）："
echo " [1] Note - 第二大脑笔记虾（知识管理、素材提供）"
echo " [2] Content - 内容创作（文章、报告、文案）"
echo " [3] Moments - 朋友圈创作（社交媒体）"
echo " [4] Video Director - 视频导演（脚本、分镜）"
echo " [5] Image Generator - 图片生成（封面、配图）"
echo " [6] Seedance Director - Seedance 导演（AI 视频提示词）"
echo " [0] 全部创建（6 个 Agent）"
echo ""

read -p "选择（直接回车自动匹配）: " AGENT_CHOICE

# 自动匹配逻辑
if [ -z "$AGENT_CHOICE" ] || [ "$AGENT_CHOICE" = "0" ]; then
  echo "🤖 自动匹配 Agent..."
  
  # 根据机器人名称自动匹配
  if [[ "$BOT_NAME" =~ (内容 | 创作|Content) ]]; then
    SELECTED_AGENTS="Note,Content"
    echo "✅ 自动匹配：第二大脑笔记虾 + Content Agent（内容创作）"
  elif [[ "$BOT_NAME" =~ (笔记|Note|知识) ]]; then
    SELECTED_AGENTS="Note"
    echo "✅ 自动匹配：Note（笔记虾）"
  elif [[ "$BOT_NAME" =~ (朋友圈|Moments|社交) ]]; then
    SELECTED_AGENTS="Note,Moments"
    echo "✅ 自动匹配：第二大脑笔记虾 + Moments（朋友圈）"
  elif [[ "$BOT_NAME" =~ (视频|Video|导演) ]]; then
    SELECTED_AGENTS="Note,Video Director,Seedance Director"
    echo "✅ 自动匹配：第二大脑笔记虾 + Video Director + Seedance Director"
  elif [[ "$BOT_NAME" =~ (图片|Image|设计) ]]; then
    SELECTED_AGENTS="Note,Image Generator"
    echo "✅ 自动匹配：第二大脑笔记虾 + Image Generator"
  else
    SELECTED_AGENTS="Note,Content"
    echo "✅ 默认匹配：第二大脑笔记虾 + Content Agent（内容创作）"
  fi
else
  # 手动选择
  SELECTED_AGENTS=""
  IFS=',' read -ra CHOICES <<< "$AGENT_CHOICE"
  for choice in "${CHOICES[@]}"; do
    case $choice in
      1) SELECTED_AGENTS="${SELECTED_AGENTS}Note," ;;
      2) SELECTED_AGENTS="${SELECTED_AGENTS}Content," ;;
      3) SELECTED_AGENTS="${SELECTED_AGENTS}Moments," ;;
      4) SELECTED_AGENTS="${SELECTED_AGENTS}Video Director," ;;
      5) SELECTED_AGENTS="${SELECTED_AGENTS}Image Generator," ;;
      6) SELECTED_AGENTS="${SELECTED_AGENTS}Seedance Director," ;;
    esac
  done
  SELECTED_AGENTS=${SELECTED_AGENTS%,}
fi

echo ""

# 生成配置文件
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CONFIG_FILE="$OPENCLAW_DIR/bot-configs/bot-config_${TIMESTAMP}.json"

cat > "$CONFIG_FILE" << EOF
{
  "robot_name": "$BOT_NAME",
  "app_id": "$APP_ID",
  "app_secret": "$APP_SECRET",
  "model": "$MODEL",
  "agents": "$(echo $SELECTED_AGENTS | jq -R 'split(",")')",
  "created_at": "$(date -Iseconds)",
  "version": "4.0.2"
}
EOF

echo "✅ 配置文件已生成：$CONFIG_FILE"
echo ""

# 生成本地文档
DOC_FILE="$OPENCLAW_DIR/bot-configs/bot-setup_${TIMESTAMP}.md"
cat > "$DOC_FILE" << EOF
# 飞书机器人配置文档

## 配置信息

- **机器人名称**: $BOT_NAME
- **App ID**: $APP_ID
- **App Secret**: ${APP_SECRET:0:10}...
- **大模型**: $MODEL
- **Agent 列表**: $SELECTED_AGENTS
- **配置时间**: $(date)
- **配置文件**: $CONFIG_FILE

## 下一步

1. 重启 Gateway: \`openclaw gateway restart\`
2. 在飞书中测试机器人
3. 开始使用机器人进行内容创作

## 使用示例

### 创作文章
笔记虾，帮我搜索全网关于 AI 视频生成的最新资料
创作虾，使用笔记虾的资料写一篇 AI 视频生成教程文章

### 生成朋友圈
笔记虾，找一些关于时间管理的金句和案例
朋友圈虾，帮我写 3 条关于时间管理的朋友圈文案
EOF

echo "✅ 配置文档已生成：$DOC_FILE"
echo ""

echo "🎉 配置完成！"
echo ""
echo "下一步："
echo "  1. 重启 Gateway: openclaw gateway restart"
echo "  2. 在飞书机器人对话中测试"
echo ""
EOFSCRIPT

  chmod +x scripts/configure-bot.sh
  echo "✓ 已创建 scripts/configure-bot.sh"
fi

echo ""
echo "✅ 安装完成！"
echo ""
echo "📍 安装位置：$SKILLS_DIR/content-creation-multi-agent"
echo ""
echo "🚀 下一步："
echo "   1. 运行配置脚本:"
echo "      cd $SKILLS_DIR/content-creation-multi-agent"
echo "      bash scripts/configure-bot.sh"
echo ""
echo "   2. 重启 Gateway:"
echo "      openclaw gateway restart"
echo ""
echo "   3. 在飞书机器人对话中测试"
echo ""
echo "📖 查看文档：cat README.md"
echo ""
