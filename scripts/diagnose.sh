#!/bin/bash

# 配置检查和问题诊断脚本 v4.0.3
# 用于排查飞书机器人无响应问题

set -e

echo "🔍 内容生成多 Agent 系统 - 诊断工具 v4.0.3"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 获取工作目录
WORKSPACE_DIR="$HOME/.openclaw/workspace-main"
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
  WORKSPACE_DIR="$USERPROFILE/.openclaw/workspace-main"
fi

SKILLS_DIR="$WORKSPACE_DIR/skills/content-creation-multi-agent"
CONFIGS_DIR="$WORKSPACE_DIR/bot-configs"
LOGS_DIR="$WORKSPACE_DIR/logs"

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

check_pass() {
  echo -e "${GREEN}✅ PASS${NC}: $1"
  ((PASS_COUNT++))
}

check_fail() {
  echo -e "${RED}❌ FAIL${NC}: $1"
  ((FAIL_COUNT++))
}

check_warn() {
  echo -e "${YELLOW}⚠️  WARN${NC}: $1"
  ((WARN_COUNT++))
}

# 1. 检查工作目录
echo "1️⃣  检查工作目录..."
if [ -d "$WORKSPACE_DIR" ]; then
  check_pass "工作目录存在：$WORKSPACE_DIR"
else
  check_fail "工作目录不存在：$WORKSPACE_DIR"
  echo "   💡 请确认 OpenClaw 已正确安装"
fi
echo ""

# 2. 检查技能文件
echo "2️⃣  检查技能文件..."
REQUIRED_FILES=("README.md" "SKILL.md" "package.json" "index.js" "install.sh")
for file in "${REQUIRED_FILES[@]}"; do
  if [ -f "$SKILLS_DIR/$file" ]; then
    check_pass "$file 存在"
  else
    check_fail "$file 缺失"
  fi
done
echo ""

# 3. 检查配置目录
echo "3️⃣  检查配置目录..."
if [ -d "$CONFIGS_DIR" ]; then
  check_pass "配置目录存在"
  
  CONFIG_COUNT=$(ls -1 "$CONFIGS_DIR"/bot-config_*.json 2>/dev/null | wc -l | tr -d ' ')
  if [ "$CONFIG_COUNT" -gt 0 ]; then
    check_pass "找到 $CONFIG_COUNT 个配置文件"
    
    echo ""
    echo "   📋 配置文件列表:"
    for config_file in "$CONFIGS_DIR"/bot-config_*.json; do
      if [ -f "$config_file" ]; then
        filename=$(basename "$config_file")
        robot_name=$(grep -o '"robot_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$config_file" 2>/dev/null | cut -d'"' -f4 || echo "未知")
        echo "      - $filename (机器人：$robot_name)"
      fi
    done
  else
    check_fail "未找到配置文件"
    echo ""
    echo "   💡 请运行配置脚本创建配置:"
    echo "      cd $SKILLS_DIR"
    echo "      bash scripts/configure-bot.sh"
  fi
else
  check_fail "配置目录不存在：$CONFIGS_DIR"
  echo ""
  echo "   💡 请运行配置脚本:"
  echo "      cd $SKILLS_DIR"
  echo "      bash scripts/configure-bot.sh"
fi
echo ""

# 4. 检查配置文件内容
echo "4️⃣  检查配置文件内容..."
if [ -d "$CONFIGS_DIR" ]; then
  for config_file in "$CONFIGS_DIR"/bot-config_*.json; do
    if [ -f "$config_file" ]; then
      filename=$(basename "$config_file")
      echo "   📄 检查：$filename"
      
      # 检查必需字段
      if grep -q '"robot_name"' "$config_file"; then
        check_pass "  robot_name 字段存在"
      else
        check_fail "  robot_name 字段缺失"
      fi
      
      if grep -q '"app_id"' "$config_file"; then
        check_pass "  app_id 字段存在"
      else
        check_fail "  app_id 字段缺失"
      fi
      
      if grep -q '"app_secret"' "$config_file"; then
        app_secret=$(grep -o '"app_secret"[[:space:]]*:[[:space:]]*"[^"]*"' "$config_file" | cut -d'"' -f4)
        if [ -n "$app_secret" ] && [ "$app_secret" != "xxx" ]; then
          check_pass "  app_secret 已配置"
        else
          check_warn "  app_secret 未配置或使用默认值"
        fi
      else
        check_fail "  app_secret 字段缺失"
      fi
      
      if grep -q '"agents"' "$config_file"; then
        agents=$(grep -o '"agents"[[:space:]]*:[[:space:]]*\[[^]]*\]' "$config_file" | cut -d'[' -f2 | cut -d']' -f1)
        check_pass "  agents 字段存在：$agents"
      else
        check_warn "  agents 字段缺失，将使用默认 Agent"
      fi
    fi
  done
fi
echo ""

# 5. 检查 Node.js
echo "5️⃣  检查 Node.js..."
if command -v node &> /dev/null; then
  NODE_VERSION=$(node -v)
  check_pass "Node.js 已安装：$NODE_VERSION"
  
  # 检查版本
  NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d'v' -f2 | cut -d'.' -f1)
  if [ "$NODE_MAJOR" -ge 18 ]; then
    check_pass "Node.js 版本符合要求 (>= 18.0.0)"
  else
    check_fail "Node.js 版本过低 (需要 >= 18.0.0)"
  fi
else
  check_fail "Node.js 未安装"
  echo ""
  echo "   💡 请安装 Node.js: https://nodejs.org"
fi
echo ""

# 6. 检查依赖
echo "6️⃣  检查依赖..."
if [ -d "$SKILLS_DIR/node_modules" ]; then
  check_pass "node_modules 目录存在"
  
  if [ -f "$SKILLS_DIR/package.json" ]; then
    if grep -q "openclaw-sdk" "$SKILLS_DIR/package.json"; then
      check_pass "openclaw-sdk 依赖已声明"
    else
      check_warn "openclaw-sdk 依赖未声明"
    fi
  fi
else
  check_warn "node_modules 目录不存在"
  echo ""
  echo "   💡 请安装依赖:"
  echo "      cd $SKILLS_DIR"
  echo "      npm install"
fi
echo ""

# 7. 检查日志目录
echo "7️⃣  检查日志..."
if [ -d "$LOGS_DIR" ]; then
  check_pass "日志目录存在"
  
  LOG_COUNT=$(ls -1 "$LOGS_DIR"/*.log 2>/dev/null | wc -l | tr -d ' ')
  if [ "$LOG_COUNT" -gt 0 ]; then
    echo ""
    echo "   📝 日志文件:"
    for log_file in "$LOGS_DIR"/*.log; do
      if [ -f "$log_file" ]; then
        filename=$(basename "$log_file")
        size=$(ls -lh "$log_file" | awk '{print $5}')
        echo "      - $filename ($size)"
      fi
    done
  else
    check_warn "未找到日志文件"
  fi
else
  check_warn "日志目录不存在"
fi
echo ""

# 8. 检查 Gateway 状态
echo "8️⃣  检查 Gateway 状态..."
if command -v openclaw &> /dev/null; then
  if openclaw status &> /dev/null; then
    check_pass "Gateway 运行正常"
  else
    check_warn "Gateway 可能未运行"
    echo ""
    echo "   💡 请检查 Gateway 状态:"
    echo "      openclaw status"
  fi
else
  check_fail "openclaw 命令未找到"
  echo ""
  echo "   💡 请确认 OpenClaw 已正确安装"
fi
echo ""

# 总结
echo "=========================================="
echo "📊 诊断结果总结"
echo "=========================================="
echo -e "${GREEN}通过：$PASS_COUNT${NC}"
echo -e "${RED}失败：$FAIL_COUNT${NC}"
echo -e "${YELLOW}警告：$WARN_COUNT${NC}"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo -e "${RED}❌ 发现 $FAIL_COUNT 个问题需要修复${NC}"
  echo ""
  echo "💡 建议操作:"
  echo "   1. 根据上述失败项进行修复"
  echo "   2. 重新运行配置脚本：bash scripts/configure-bot.sh"
  echo "   3. 重启 Gateway: openclaw gateway restart"
  exit 1
elif [ "$WARN_COUNT" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  发现 $WARN_COUNT 个警告，建议检查${NC}"
  echo ""
  echo "💡 建议操作:"
  echo "   1. 查看警告项并确认是否影响使用"
  echo "   2. 在飞书机器人对话中测试发送消息"
  echo "   3. 查看日志排查问题：tail -f $LOGS_DIR/*.log"
  exit 0
else
  echo -e "${GREEN}✅ 所有检查通过！${NC}"
  echo ""
  echo "💡 下一步:"
  echo "   1. 在飞书机器人对话中发送消息测试"
  echo "   2. 查看实时日志：tail -f $LOGS_DIR/*.log"
  echo "   3. 如仍有问题，检查飞书应用配置和权限"
  exit 0
fi
