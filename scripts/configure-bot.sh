#!/bin/bash

# 智能飞书机器人配置脚本 v4.0.5
# 支持自定义机器人名称、自动匹配 Agent、智能创建技能

set -e

echo "🤖 智能飞书机器人配置助手 v4.0.5"
echo "======================================"
echo ""

# 配置目录
WORKSPACE_DIR="$HOME/.openclaw/workspace-main"
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
  WORKSPACE_DIR="$USERPROFILE/.openclaw/workspace-main"
fi

CONFIGS_DIR="$WORKSPACE_DIR/bot-configs"
SKILLS_DIR="$WORKSPACE_DIR/skills/content-creation-multi-agent"

# 创建配置目录
mkdir -p "$CONFIGS_DIR"

echo "📂 工作目录：$WORKSPACE_DIR"
echo "📂 配置目录：$CONFIGS_DIR"
echo ""

# 预设机器人名称与 Agent 匹配规则
declare -A ROBOT_AGENT_MAP
ROBOT_AGENT_MAP["笔记"]="Note"
ROBOT_AGENT_MAP["笔记虾"]="Note"
ROBOT_AGENT_MAP["第二大脑"]="Note"
ROBOT_AGENT_MAP["知识"]="Note"
ROBOT_AGENT_MAP["内容"]="Content"
ROBOT_AGENT_MAP["创作"]="Content"
ROBOT_AGENT_MAP["文章"]="Content"
ROBOT_AGENT_MAP["朋友圈"]="Moments"
ROBOT_AGENT_MAP["社交"]="Moments"
ROBOT_AGENT_MAP["媒体"]="Moments"
ROBOT_AGENT_MAP["视频"]="Video Director,Seedance Director"
ROBOT_AGENT_MAP["导演"]="Video Director,Seedance Director"
ROBOT_AGENT_MAP["脚本"]="Video Director"
ROBOT_AGENT_MAP["图片"]="Image Generator"
ROBOT_AGENT_MAP["设计"]="Image Generator"
ROBOT_AGENT_MAP["封面"]="Image Generator"
ROBOT_AGENT_MAP["Seedance"]="Seedance Director"
ROBOT_AGENT_MAP["提示词"]="Seedance Director"

# Agent 完整列表
declare -A AGENT_LIST
AGENT_LIST["Note"]="第二大脑笔记虾（知识管理、素材提供）"
AGENT_LIST["Content"]="内容创作（文章、报告、文案）"
AGENT_LIST["Moments"]="朋友圈创作（社交媒体）"
AGENT_LIST["Video Director"]="视频导演（脚本、分镜）"
AGENT_LIST["Image Generator"]="图片生成（封面、配图）"
AGENT_LIST["Seedance Director"]="Seedance 导演（AI 视频提示词）"

# 显示可用 Agent
echo "📋 可用 Agent 列表:"
for agent in "${!AGENT_LIST[@]}"; do
  echo "   - $agent: ${AGENT_LIST[$agent]}"
done
echo ""

# 输入机器人名称
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "步骤 1: 配置飞书机器人"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "请输入飞书机器人名称（示例：来合火 1 号第二大脑笔记虾）: " ROBOT_NAME

if [ -z "$ROBOT_NAME" ]; then
  echo "❌ 机器人名称不能为空"
  exit 1
fi

echo "✅ 机器人名称：$ROBOT_NAME"
echo ""

# 自动匹配 Agent
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "步骤 2: 自动匹配 Agent"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

MATCHED_AGENTS=""
ROBOT_NAME_LOWER=$(echo "$ROBOT_NAME" | tr '[:upper:]' '[:lower:]')

# 遍历匹配规则
for keyword in "${!ROBOT_AGENT_MAP[@]}"; do
  if [[ "$ROBOT_NAME_LOWER" == *"$keyword"* ]]; then
    if [ -n "$MATCHED_AGENTS" ]; then
      MATCHED_AGENTS="$MATCHED_AGENTS,${ROBOT_AGENT_MAP[$keyword]}"
    else
      MATCHED_AGENTS="${ROBOT_AGENT_MAP[$keyword]}"
    fi
  fi
done

# 如果没有匹配到，使用默认配置
if [ -z "$MATCHED_AGENTS" ]; then
  echo "⚠️  未从名称中匹配到特定 Agent"
  echo ""
  echo "请选择要创建的 Agent（输入序号，多个用逗号分隔）:"
  echo "   [1] Note - 第二大脑笔记虾"
  echo "   [2] Content - 内容创作"
  echo "   [3] Moments - 朋友圈创作"
  echo "   [4] Video Director - 视频导演"
  echo "   [5] Image Generator - 图片生成"
  echo "   [6] Seedance Director - Seedance 导演"
  echo "   [0] 全部创建"
  echo ""
  read -p "选择： " AGENT_CHOICE
  
  if [ "$AGENT_CHOICE" = "0" ]; then
    MATCHED_AGENTS="Note,Content,Moments,Video Director,Image Generator,Seedance Director"
  else
    IFS=',' read -ra CHOICES <<< "$AGENT_CHOICE"
    for choice in "${CHOICES[@]}"; do
      case $choice in
        1) MATCHED_AGENTS="${MATCHED_AGENTS}Note," ;;
        2) MATCHED_AGENTS="${MATCHED_AGENTS}Content," ;;
        3) MATCHED_AGENTS="${MATCHED_AGENTS}Moments," ;;
        4) MATCHED_AGENTS="${MATCHED_AGENTS}Video Director," ;;
        5) MATCHED_AGENTS="${MATCHED_AGENTS}Image Generator," ;;
        6) MATCHED_AGENTS="${MATCHED_AGENTS}Seedance Director," ;;
      esac
    done
    MATCHED_AGENTS=${MATCHED_AGENTS%,}
  fi
else
  echo "🤖 自动匹配结果："
  IFS=',' read -ra AGENTS <<< "$MATCHED_AGENTS"
  for agent in "${AGENTS[@]}"; do
    if [ -n "${AGENT_LIST[$agent]}" ]; then
      echo "   ✅ $agent - ${AGENT_LIST[$agent]}"
    fi
  done
  echo ""
  
  # 确认是否修改
  read -p "是否修改自动匹配的 Agent？(y/N): " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "请选择要创建的 Agent:"
    echo "   [1] Note - 第二大脑笔记虾"
    echo "   [2] Content - 内容创作"
    echo "   [3] Moments - 朋友圈创作"
    echo "   [4] Video Director - 视频导演"
    echo "   [5] Image Generator - 图片生成"
    echo "   [6] Seedance Director - Seedance 导演"
    echo "   [0] 全部创建"
    echo ""
    read -p "选择： " AGENT_CHOICE
    
    if [ "$AGENT_CHOICE" = "0" ]; then
      MATCHED_AGENTS="Note,Content,Moments,Video Director,Image Generator,Seedance Director"
    else
      NEW_AGENTS=""
      IFS=',' read -ra CHOICES <<< "$AGENT_CHOICE"
      for choice in "${CHOICES[@]}"; do
        case $choice in
          1) NEW_AGENTS="${NEW_AGENTS}Note," ;;
          2) NEW_AGENTS="${NEW_AGENTS}Content," ;;
          3) NEW_AGENTS="${NEW_AGENTS}Moments," ;;
          4) NEW_AGENTS="${NEW_AGENTS}Video Director," ;;
          5) NEW_AGENTS="${NEW_AGENTS}Image Generator," ;;
          6) NEW_AGENTS="${NEW_AGENTS}Seedance Director," ;;
        esac
      done
      MATCHED_AGENTS=${NEW_AGENTS%,}
    fi
  fi
fi

echo "✅ 最终 Agent: $MATCHED_AGENTS"
echo ""

# 输入飞书应用凭证
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "步骤 3: 配置飞书应用凭证"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "App ID（必填，格式：cli_xxx）: " APP_ID
if [ -z "$APP_ID" ]; then
  echo "❌ App ID 不能为空"
  exit 1
fi

read -p "App Secret（必填）: " APP_SECRET
if [ -z "$APP_SECRET" ]; then
  echo "❌ App Secret 不能为空"
  exit 1
fi

echo "✅ 飞书应用凭证已配置"
echo ""

# 配置大模型
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "步骤 4: 配置大模型"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "提示：可以指定已经配置好的模型，也可以为空自动配置默认大模型"
read -p "大模型名称（默认：doubao）: " MODEL
MODEL=${MODEL:-doubao}
echo "✅ 大模型名称：$MODEL"
echo ""

# 生成配置文件
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "步骤 5: 生成配置文件"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SAFE_NAME=$(echo "$ROBOT_NAME" | tr ' ' '_' | tr -cd '[:alnum:]_中文')
CONFIG_FILE="$CONFIGS_DIR/bot-config_${SAFE_NAME}_${TIMESTAMP}.json"

# 构建 agents JSON 数组
IFS=',' read -ra AGENTS_ARR <<< "$MATCHED_AGENTS"
AGENTS_JSON="["
first=true
for agent in "${AGENTS_ARR[@]}"; do
  if [ "$first" = true ]; then
    AGENTS_JSON="$AGENTS_JSON\"$agent\""
    first=false
  else
    AGENTS_JSON="$AGENTS_JSON, \"$agent\""
  fi
done
AGENTS_JSON="$AGENTS_JSON]"

# 写入配置文件
cat > "$CONFIG_FILE" << EOF
{
  "robot_name": "$ROBOT_NAME",
  "app_id": "$APP_ID",
  "app_secret": "$APP_SECRET",
  "model": "$MODEL",
  "agents": $AGENTS_JSON,
  "created_at": "$(date -Iseconds)",
  "version": "4.0.5"
}
EOF

echo "✅ 配置文件已生成：$CONFIG_FILE"
echo ""

# 显示配置信息
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 配置信息总结"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🤖 机器人名称：$ROBOT_NAME"
echo "🔑 App ID: $APP_ID"
echo "🔒 App Secret: ${APP_SECRET:0:10}..."
echo "🧠 大模型：$MODEL"
echo "🎭 Agent 列表：$MATCHED_AGENTS"
echo "📄 配置文件：$CONFIG_FILE"
echo ""

# 生成配置文档
DOC_FILE="$CONFIGS_DIR/bot-setup_${SAFE_NAME}_${TIMESTAMP}.md"
cat > "$DOC_FILE" << EOF
# 飞书机器人配置文档

_配置时间：$(date)_

## 基本信息

- **机器人名称**: $ROBOT_NAME
- **App ID**: $APP_ID
- **App Secret**: ${APP_SECRET:0:10}...
- **大模型**: $MODEL
- **Agent 列表**: $MATCHED_AGENTS

## 配置文件

位置：\`$CONFIG_FILE\`

## 下一步

1. **重启 Gateway**:
   \`\`\`bash
   openclaw gateway restart
   \`\`\`

2. **在飞书中测试**:
   - 在飞书中搜索：$ROBOT_NAME
   - 发送测试消息："你好"
   - 发送功能测试："笔记虾，帮我搜索 AI 资料"

3. **查看日志**:
   \`\`\`bash
   tail -f ~/.openclaw/logs/*.log
   \`\`\`

## 使用示例

EOF

# 根据配置的 Agent 生成使用示例
for agent in "${AGENTS_ARR[@]}"; do
  case $agent in
    "Note")
      cat >> "$DOC_FILE" << EOF
### 笔记虾功能
\`\`\`
笔记虾，帮我搜索全网关于 AI 的最新资料
笔记虾，帮我整理时间管理的方法论
\`\`\`

EOF
      ;;
    "Content")
      cat >> "$DOC_FILE" << EOF
### 内容创作功能
\`\`\`
创作虾，帮我写一篇 AI 发展趋势文章
创作虾，帮我写一个产品报告
\`\`\`

EOF
      ;;
    "Moments")
      cat >> "$DOC_FILE" << EOF
### 朋友圈功能
\`\`\`
朋友圈虾，帮我写 3 条正能量文案
朋友圈虾，帮我写小红书笔记
\`\`\`

EOF
      ;;
    "Video Director")
      cat >> "$DOC_FILE" << EOF
### 视频导演功能
\`\`\`
视频虾，帮我写一个 60 秒视频脚本
视频虾，帮我设计产品宣传视频分镜
\`\`\`

EOF
      ;;
    "Image Generator")
      cat >> "$DOC_FILE" << EOF
### 图片生成功能
\`\`\`
图片虾，帮我生成一张科技感封面图
图片虾，帮我设计海报，尺寸 1080x1080
\`\`\`

EOF
      ;;
    "Seedance Director")
      cat >> "$DOC_FILE" << EOF
### Seedance 导演功能
\`\`\`
Seedance 虾，帮我生成 AI 视频提示词
Seedance 虾，帮我设计 60 秒视频提示词
\`\`\`

EOF
      ;;
  esac
done

cat >> "$DOC_FILE" << EOF
## 故障排查

如果机器人无响应：

1. 检查 Gateway 状态：\`openclaw status\`
2. 运行诊断工具：\`bash scripts/diagnose.sh\`
3. 查看日志：\`tail -f ~/.openclaw/logs/*.log\`
4. 重新配置：\`bash scripts/configure-bot.sh\`

## 相关文档

- 快速配置指南：QUICK_START.md
- 多机器人配置：docs/MULTI_BOT_SETUP.md
- 问题排查：docs/TROUBLESHOOTING.md
EOF

echo "📝 配置文档已生成：$DOC_FILE"
echo ""

# 提示重启
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 配置完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 下一步:"
echo "   1. 重启 Gateway（必须）:"
echo "      openclaw gateway restart"
echo ""
echo "   2. 等待 20-30 秒让 Gateway 完全重启"
echo ""
echo "   3. 在飞书中测试:"
echo "      - 搜索：$ROBOT_NAME"
echo "      - 发送：你好"
echo ""
echo "   4. 查看配置文档:"
echo "      cat $DOC_FILE"
echo ""

# 询问是否继续配置其他机器人
echo ""
read -p "是否继续配置其他飞书机器人？(y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "开始配置下一个机器人"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  exec "$0"
else
  echo ""
  echo "🎉 所有配置完成！"
  echo ""
  echo "📊 已配置的机器人:"
  ls -1 "$CONFIGS_DIR"/bot-config_*.json 2>/dev/null | while read file; do
    robot_name=$(grep -o '"robot_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$file" | cut -d'"' -f4)
    echo "   🤖 $robot_name"
  done
  echo ""
  echo "💡 记住：配置完成后必须重启 Gateway 才能生效！"
  echo "   openclaw gateway restart"
  echo ""
fi
