#!/bin/bash

# 多机器人配置生成脚本 v4.0.4
# 用于批量创建多个飞书机器人配置

set -e

echo "🤖 多机器人配置生成工具 v4.0.4"
echo "=================================="
echo ""

# 配置目录
CONFIGS_DIR="$HOME/.openclaw/workspace-main/bot-configs"
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
  CONFIGS_DIR="$USERPROFILE/.openclaw/workspace-main/bot-configs"
fi

# 创建配置目录
mkdir -p "$CONFIGS_DIR"

echo "📂 配置目录：$CONFIGS_DIR"
echo ""

# 预设的 Agent 配置模板
declare -A AGENT_TEMPLATES
AGENT_TEMPLATES["内容创作"]="Note,Content"
AGENT_TEMPLATES["朋友圈助手"]="Note,Moments"
AGENT_TEMPLATES["视频导演"]="Note,Video Director,Seedance Director"
AGENT_TEMPLATES["图片生成"]="Note,Image Generator"
AGENT_TEMPLATES["笔记虾"]="Note"
AGENT_TEMPLATES["自媒体运营"]="Note,Content,Moments,Image Generator"

# 显示预设模板
echo "📋 预设的机器人配置模板:"
echo ""
index=1
for name in "${!AGENT_TEMPLATES[@]}"; do
  echo "   [$index] $name - Agent: ${AGENT_TEMPLATES[$name]}"
  ((index++))
done
echo ""

# 询问是否使用预设模板
read -p "是否使用预设模板？(y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -p "请选择模板序号（输入多个用逗号分隔，如 1,2,3）: " TEMPLATE_CHOICES
  
  IFS=',' read -ra CHOICES <<< "$TEMPLATE_CHOICES"
  for choice in "${CHOICES[@]}"; do
    index=1
    for name in "${!AGENT_TEMPLATES[@]}"; do
      if [ "$index" -eq "$choice" ]; then
        echo ""
        echo "🔧 配置机器人：$name"
        echo "   Agent: ${AGENT_TEMPLATES[$name]}"
        
        # 输入 App ID 和 App Secret
        read -p "   请输入 App ID: " APP_ID
        read -p "   请输入 App Secret: " APP_SECRET
        
        if [ -z "$APP_ID" ] || [ -z "$APP_SECRET" ]; then
          echo "   ❌ App ID 和 App Secret 不能为空，跳过此配置"
          continue
        fi
        
        # 选择大模型
        read -p "   大模型名称（默认：doubao）: " MODEL
        MODEL=${MODEL:-doubao}
        
        # 生成配置文件
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        SAFE_NAME=$(echo "$name" | tr ' ' '_' | tr -cd '[:alnum:]_')
        CONFIG_FILE="$CONFIGS_DIR/bot-config_${SAFE_NAME}_${TIMESTAMP}.json"
        
        # 构建 agents JSON 数组
        IFS=',' read -ra AGENTS <<< "${AGENT_TEMPLATES[$name]}"
        AGENTS_JSON="["
        first=true
        for agent in "${AGENTS[@]}"; do
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
  "robot_name": "$name",
  "app_id": "$APP_ID",
  "app_secret": "$APP_SECRET",
  "model": "$MODEL",
  "agents": $AGENTS_JSON,
  "created_at": "$(date -Iseconds)",
  "version": "4.0.4"
}
EOF
        
        echo "   ✅ 配置已生成：$CONFIG_FILE"
        echo ""
      fi
      ((index++))
    done
  done
else
  # 自定义配置
  echo "🔧 自定义配置模式"
  echo ""
  
  while true; do
    read -p "请输入机器人名称（或输入 q 退出）: " ROBOT_NAME
    
    if [ "$ROBOT_NAME" = "q" ] || [ "$ROBOT_NAME" = "quit" ]; then
      break
    fi
    
    if [ -z "$ROBOT_NAME" ]; then
      echo "   ❌ 机器人名称不能为空"
      continue
    fi
    
    # 输入 App ID 和 App Secret
    read -p "请输入 App ID: " APP_ID
    read -p "请输入 App Secret: " APP_SECRET
    
    if [ -z "$APP_ID" ] || [ -z "$APP_SECRET" ]; then
      echo "   ❌ App ID 和 App Secret 不能为空"
      continue
    fi
    
    # 选择 Agent
    echo ""
    echo "   请选择要配置的 Agent（输入序号，多个用逗号分隔）:"
    echo "   [1] Note - 第二大脑笔记虾"
    echo "   [2] Content - 内容创作"
    echo "   [3] Moments - 朋友圈创作"
    echo "   [4] Video Director - 视频导演"
    echo "   [5] Image Generator - 图片生成"
    echo "   [6] Seedance Director - Seedance 导演"
    echo "   [0] 全部创建"
    echo ""
    
    read -p "   选择： " AGENT_CHOICE
    
    # 构建 Agent 列表
    if [ "$AGENT_CHOICE" = "0" ]; then
      AGENTS="Note,Content,Moments,Video Director,Image Generator,Seedance Director"
    else
      AGENTS=""
      IFS=',' read -ra CHOICES <<< "$AGENT_CHOICE"
      for choice in "${CHOICES[@]}"; do
        case $choice in
          1) AGENTS="${AGENTS}Note," ;;
          2) AGENTS="${AGENTS}Content," ;;
          3) AGENTS="${AGENTS}Moments," ;;
          4) AGENTS="${AGENTS}Video Director," ;;
          5) AGENTS="${AGENTS}Image Generator," ;;
          6) AGENTS="${AGENTS}Seedance Director," ;;
        esac
      done
      AGENTS=${AGENTS%,}
    fi
    
    # 选择大模型
    read -p "   大模型名称（默认：doubao）: " MODEL
    MODEL=${MODEL:-doubao}
    
    # 生成配置文件
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    SAFE_NAME=$(echo "$ROBOT_NAME" | tr ' ' '_' | tr -cd '[:alnum:]_')
    CONFIG_FILE="$CONFIGS_DIR/bot-config_${SAFE_NAME}_${TIMESTAMP}.json"
    
    # 构建 agents JSON 数组
    IFS=',' read -ra AGENTS_ARR <<< "$AGENTS"
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
  "version": "4.0.4"
}
EOF
    
    echo "   ✅ 配置已生成：$CONFIG_FILE"
    echo ""
  done
fi

echo ""
echo "=================================="
echo "✅ 配置生成完成！"
echo ""
echo "📋 已生成的配置文件:"
ls -1 "$CONFIGS_DIR"/bot-config_*.json 2>/dev/null | while read file; do
  echo "   - $(basename "$file")"
done
echo ""

# 统计配置数量
CONFIG_COUNT=$(ls -1 "$CONFIGS_DIR"/bot-config_*.json 2>/dev/null | wc -l | tr -d ' ')
echo "📊 共配置了 $CONFIG_COUNT 个机器人"
echo ""

echo "🚀 下一步:"
echo "   1. 重启 Gateway: openclaw gateway restart"
echo "   2. 在飞书中测试每个机器人"
echo "   3. 运行诊断：bash scripts/diagnose.sh"
echo ""

# 生成配置总结文档
SUMMARY_FILE="$CONFIGS_DIR/bot-configs-summary-$(date +%Y%m%d).md"
cat > "$SUMMARY_FILE" << EOF
# 飞书机器人配置总结

_生成时间：$(date)_

## 配置列表

EOF

ls -1 "$CONFIGS_DIR"/bot-config_*.json 2>/dev/null | while read file; do
  robot_name=$(grep -o '"robot_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$file" | cut -d'"' -f4)
  agents=$(grep -o '"agents"[[:space:]]*:[[:space:]]*\[[^]]*\]' "$file")
  echo "- **$robot_name**: $agents" >> "$SUMMARY_FILE"
done

cat >> "$SUMMARY_FILE" << EOF

## 下一步

1. 重启 Gateway: \`openclaw gateway restart\`
2. 在飞书中测试每个机器人
3. 查看配置详情：\`cat ~/.openclaw/workspace-main/bot-configs/bot-config_*.json\`

## 注意事项

- 每个机器人的 App ID 和 App Secret 必须唯一
- 确保每个飞书应用都已配置事件订阅
- 确保所有应用都已发布并审批通过
EOF

echo "📝 配置总结已生成：$SUMMARY_FILE"
echo ""
