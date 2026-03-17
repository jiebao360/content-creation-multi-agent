#!/bin/bash

# 飞书机器人消息监听器 v4.0.3
# 用于监听和处理飞书机器人消息

set -e

echo "🤖 启动飞书机器人消息监听器..."
echo ""

# 获取工作目录
WORKSPACE_DIR="$HOME/.openclaw/workspace-main"
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
  WORKSPACE_DIR="$USERPROFILE/.openclaw/workspace-main"
fi

SKILLS_DIR="$WORKSPACE_DIR/skills/content-creation-multi-agent"
LOGS_DIR="$WORKSPACE_DIR/logs"
CONFIGS_DIR="$WORKSPACE_DIR/bot-configs"

# 创建日志目录
mkdir -p "$LOGS_DIR"

# 日志文件
LOG_FILE="$LOGS_DIR/feishu-bot-$(date +%Y%m%d).log"

echo "📂 工作目录：$WORKSPACE_DIR"
echo "📂 技能目录：$SKILLS_DIR"
echo "📂 配置目录：$CONFIGS_DIR"
echo "📝 日志文件：$LOG_FILE"
echo ""

# 检查配置
if [ ! -d "$CONFIGS_DIR" ]; then
  echo "❌ 配置目录不存在！"
  echo "💡 请先运行配置脚本："
  echo "   cd $SKILLS_DIR"
  echo "   bash scripts/configure-bot.sh"
  exit 1
fi

# 检查配置文件
CONFIG_COUNT=$(ls -1 "$CONFIGS_DIR"/bot-config_*.json 2>/dev/null | wc -l)
if [ "$CONFIG_COUNT" -eq 0 ]; then
  echo "❌ 未找到配置文件！"
  echo "💡 请先运行配置脚本："
  echo "   cd $SKILLS_DIR"
  echo "   bash scripts/configure-bot.sh"
  exit 1
fi

echo "✅ 找到 $CONFIG_COUNT 个配置文件"
echo ""

# 加载配置
echo "📋 已配置的机器人:"
for config_file in "$CONFIGS_DIR"/bot-config_*.json; do
  if [ -f "$config_file" ]; then
    robot_name=$(grep -o '"robot_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$config_file" | cut -d'"' -f4)
    agents=$(grep -o '"agents"[[:space:]]*:[[:space:]]*\[[^]]*\]' "$config_file" | cut -d'[' -f2 | cut -d']' -f1)
    echo "   🤖 $robot_name - Agent: $agents"
  fi
done

echo ""
echo "🚀 启动消息监听服务..."
echo ""
echo "💡 提示:"
echo "   - 在飞书机器人对话中发送消息测试"
echo "   - 查看日志：tail -f $LOG_FILE"
echo "   - 停止服务：Ctrl+C"
echo ""

# 启动 Node.js 监听服务
cd "$SKILLS_DIR"
node index.js 2>&1 | tee -a "$LOG_FILE"
