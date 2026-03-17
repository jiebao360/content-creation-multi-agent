# 🤖 智能配置助手使用指南 v4.0.5

> 让 AI 帮你完成飞书机器人配置

**版本**: v4.0.5  
**更新时间**: 2026-03-17

---

## 🎯 功能特性

### 支持自定义机器人名称

输入任意名称，如：
- ✅ 来合火 1 号第二大脑笔记虾
- ✅ 内容创作助手
- ✅ 朋友圈文案机器人
- ✅ 视频导演机器人

### 智能匹配 Agent

根据机器人名称自动匹配对应的 Agent：
- "笔记虾" → Note
- "内容创作" → Content
- "朋友圈" → Moments
- "视频" → Video Director + Seedance Director
- "图片" → Image Generator

### 灵活配置

- ✅ 飞书应用凭证可输入
- ✅ 大模型可指定或自动配置
- ✅ Agent 可手动选择或自动匹配
- ✅ 支持批量配置多个机器人

---

## 🚀 使用方式

### 方法 1: 运行配置脚本

```bash
cd ~/.openclaw/workspace-main/skills/content-creation-multi-agent
bash scripts/configure-bot.sh
```

### 方法 2: 在飞书对话中告诉 AI

**示例对话**:

```
用户：我想创建一个飞书机器人，名称叫"来合火 1 号第二大脑笔记虾"

AI: 好的！我来帮你配置。

步骤 1: 准备飞书应用凭证
- 访问 https://open.feishu.cn/
- 创建应用，获取 App ID 和 App Secret

步骤 2: 运行配置脚本
cd ~/.openclaw/workspace-main/skills/content-creation-multi-agent
bash scripts/configure-bot.sh

步骤 3: 按提示输入
- 机器人名称：来合火 1 号第二大脑笔记虾
- App ID: cli_xxx_your_id
- App Secret: your_secret
- 大模型：doubao（或直接回车）
- 创建技能：直接回车（自动匹配 Note）

步骤 4: 重启 Gateway
openclaw gateway restart

完成！现在可以在飞书中搜索"来合火 1 号第二大脑笔记虾"并测试了。
```

---

## 📋 完整配置流程

### 步骤 1: 运行脚本

```bash
bash scripts/configure-bot.sh
```

**输出**:
```
🤖 智能飞书机器人配置助手 v4.0.5
======================================

📋 可用 Agent 列表:
   - Note: 第二大脑笔记虾（知识管理、素材提供）
   - Content: 内容创作（文章、报告、文案）
   - Moments: 朋友圈创作（社交媒体）
   - Video Director: 视频导演（脚本、分镜）
   - Image Generator: 图片生成（封面、配图）
   - Seedance Director: Seedance 导演（AI 视频提示词）
```

### 步骤 2: 输入机器人名称

```
请输入飞书机器人名称（示例：来合火 1 号第二大脑笔记虾）：来合火 1 号第二大脑笔记虾
✅ 机器人名称：来合火 1 号第二大脑笔记虾
```

### 步骤 3: 自动匹配 Agent

```
🤖 自动匹配结果：
   ✅ Note - 第二大脑笔记虾（知识管理、素材提供）

是否修改自动匹配的 Agent？(y/N): 
```

**直接回车**使用自动匹配，或输入 `y` 手动修改。

### 步骤 4: 输入飞书应用凭证

```
App ID（必填，格式：cli_xxx）：cli_xxx_your_app_id
App Secret（必填）：your_app_secret
✅ 飞书应用凭证已配置
```

### 步骤 5: 配置大模型

```
提示：可以指定已经配置好的模型，也可以为空自动配置默认大模型
大模型名称（默认：doubao）：doubao
✅ 大模型名称：doubao
```

**直接回车**使用默认 doubao，或输入其他模型名称。

### 步骤 6: 生成配置文件

```
✅ 配置文件已生成：~/.openclaw/workspace-main/bot-configs/bot-config_来合火 1 号第二大脑笔记虾_20260317_163000.json

📋 配置信息总结:
🤖 机器人名称：来合火 1 号第二大脑笔记虾
🔑 App ID: cli_xxx_your_app_id
🔒 App Secret: your_app...
🧠 大模型：doubao
🎭 Agent 列表：Note
📄 配置文件：.../bot-config_xxx.json
📝 配置文档已生成：.../bot-setup_xxx.md
```

### 步骤 7: 重启 Gateway

```bash
openclaw gateway restart
```

**等待 20-30 秒**让 Gateway 完全重启。

---

## 🎭 配置示例

### 示例 1: 配置笔记虾

```bash
bash scripts/configure-bot.sh

# 输入:
机器人名称：来合火 1 号第二大脑笔记虾
App ID: cli_xxx_note
App Secret: note_secret
大模型：doubao
创建技能：直接回车（自动匹配 Note）
```

**结果**: 自动匹配 Note Agent

### 示例 2: 配置内容创作机器人

```bash
bash scripts/configure-bot.sh

# 输入:
机器人名称：内容创作助手
App ID: cli_xxx_content
App Secret: content_secret
大模型：doubao
创建技能：直接回车（自动匹配 Content）
```

**结果**: 自动匹配 Content Agent

### 示例 3: 配置视频导演机器人

```bash
bash scripts/configure-bot.sh

# 输入:
机器人名称：视频导演机器人
App ID: cli_xxx_video
App Secret: video_secret
大模型：doubao-pro
创建技能：直接回车（自动匹配 Video Director + Seedance）
```

**结果**: 自动匹配 Video Director + Seedance Director

### 示例 4: 手动选择 Agent

```bash
bash scripts/configure-bot.sh

# 输入:
机器人名称：自媒体运营机器人
App ID: cli_xxx_media
App Secret: media_secret
大模型：doubao

# 未匹配到特定 Agent，手动选择:
选择：2,3,5（Content + Moments + Image Generator）
```

**结果**: 手动选择 3 个 Agent

---

## 📊 智能匹配规则

### 完整匹配表

| 机器人名称包含 | 自动匹配 Agent | 说明 |
|---------------|---------------|------|
| 笔记、笔记虾、第二大脑、知识 | Note | 知识管理、素材提供 |
| 内容、创作、文章、写作 | Content | 文章、报告、文案 |
| 朋友圈、社交、媒体、微博 | Moments | 社交媒体内容 |
| 视频、导演、脚本、分镜 | Video Director + Seedance | 视频脚本 + AI 视频提示词 |
| 图片、设计、封面、配图 | Image Generator | 图片生成 |
| Seedance、提示词、AI 视频 | Seedance Director | AI 视频提示词 |

### 匹配优先级

1. **精确匹配**: 完全包含关键词
2. **组合匹配**: 包含多个关键词
3. **默认配置**: Note + Content

---

## 🎯 批量配置多个机器人

配置脚本支持连续配置多个机器人：

```bash
bash scripts/configure-bot.sh

# 配置完第一个机器人后
是否继续配置其他飞书机器人？(y/N): y

# 继续配置第二个
请输入飞书机器人名称：内容创作助手
...

# 配置完成后
是否继续配置其他飞书机器人？(y/N): n

🎉 所有配置完成！

📊 已配置的机器人:
   🤖 来合火 1 号第二大脑笔记虾
   🤖 内容创作助手
   🤖 朋友圈文案机器人
```

---

## 📝 生成的文件

### 1. 配置文件

位置：`~/.openclaw/workspace-main/bot-configs/`

文件名：`bot-config_机器人名称_时间戳.json`

内容示例:
```json
{
  "robot_name": "来合火 1 号第二大脑笔记虾",
  "app_id": "cli_xxx_note",
  "app_secret": "note_secret",
  "model": "doubao",
  "agents": ["Note"],
  "created_at": "2026-03-17T16:30:00+08:00",
  "version": "4.0.5"
}
```

### 2. 配置文档

位置：`~/.openclaw/workspace-main/bot-configs/`

文件名：`bot-setup_机器人名称_时间戳.md`

内容包含:
- 配置信息总结
- 配置文件位置
- 下一步操作
- 使用示例
- 故障排查

---

## 🐛 常见问题

### Q1: 名称中包含特殊字符

**解决**: 脚本会自动处理，生成安全的文件名

### Q2: 自动匹配不准确

**解决**: 
```bash
# 在"是否修改自动匹配的 Agent？"时输入 y
# 然后手动选择正确的 Agent
```

### Q3: 配置后消息无响应

**解决**:
```bash
# 1. 确认 Gateway 已重启
openclaw gateway restart

# 2. 运行诊断
bash scripts/diagnose.sh

# 3. 查看日志
tail -f ~/.openclaw/logs/*.log
```

### Q4: 如何查看已配置的机器人

```bash
# 查看配置文件
ls -la ~/.openclaw/workspace-main/bot-configs/

# 查看配置详情
cat ~/.openclaw/workspace-main/bot-configs/bot-config_*.json
```

---

## 📖 相关文档

- **快速配置**: QUICK_START.md
- **多机器人配置**: docs/MULTI_BOT_SETUP.md
- **问题排查**: docs/TROUBLESHOOTING.md
- **飞书配置**: docs/FEISHU_SETUP.md

---

## 🆘 获取帮助

### 诊断工具
```bash
bash scripts/diagnose.sh
```

### 查看日志
```bash
tail -f ~/.openclaw/logs/*.log
```

### GitHub Issues
https://github.com/jiebao360/content-creation-multi-agent/issues

---

<div align="center">

**🦞 智能配置，让每个 Agent 都有专属机器人身份！**

运行 `bash scripts/configure-bot.sh` 开始配置吧！

</div>
