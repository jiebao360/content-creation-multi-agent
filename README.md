# 🦐 内容生成多 Agent 系统 v4.0.2

> 商用级内容生成全流程系统 - 优化安装路径版本

**版本**: v4.0.2 (路径优化版)  
**创建时间**: 2026-03-17  
**作者**: OpenClaw 来合火  
**GitHub**: https://github.com/jiebao360/content-creation-multi-agent  
**Clawhub**: content-creation-multi-agent

---

## ⚠️ 重要优化说明

### 🎯 问题修复

**原问题**: Windows 系统安装位置硬编码为
```bash
❌ C:\Users\1\.openclaw\workspace\skills\content-creation-multi-agent
```

**优化后**: 统一使用标准路径
```bash
✅ ~/.openclaw/workspace-main/skills/content-creation-multi-agent
```

**Windows 自动适配**:
```bash
# 自动解析为
C:\Users\<你的用户名>\.openclaw\workspace-main\skills\content-creation-multi-agent
```

### ✨ 核心改进

1. **路径标准化** - 所有平台统一使用 `workspace-main` 目录
2. **跨平台兼容** - Windows/Mac/Linux 自动适配
3. **移除硬编码** - 不再使用固定用户名路径
4. **自动化安装** - 一键安装脚本支持所有平台

---

## 🎭 6 个专业化 Agent

| Agent | 职责 | 默认模型 | 推荐技能 |
|-------|------|----------|----------|
| **Note** | 第二大脑笔记虾（知识管理、素材提供） | doubao-pro | web-search, file-reading, knowledge-management |
| **Content** | 文章写作、报告、文案 | doubao | article-writer, ai-daily-news |
| **Moments** | 朋友圈、社交媒体 | doubao | copywriting, social-media |
| **Video Director** | 视频脚本、分镜 | doubao-pro | video-script, storyboard |
| **Image Generator** | 图片搜索、豆包生成 | doubao-pro | image-search, doubao-prompt, image-generation |
| **Seedance Director** | Seedance 提示词 | doubao-pro | seedance-prompt, video-direction, prompt-engineering |

---

## 🚀 快速安装

### 方法 1: 一键安装脚本（推荐）

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/jiebao360/content-creation-multi-agent/main/install.sh | bash
```

**Windows (Git Bash):**
```powershell
curl -fsSL https://raw.githubusercontent.com/jiebao360/content-creation-multi-agent/main/install.bat -o install.bat
.\install.bat
```

### 方法 2: 手动安装

**所有平台统一路径**:

```bash
# 1. 克隆仓库
git clone https://github.com/jiebao360/content-creation-multi-agent.git

# 2. 移动到 skills 目录（统一路径）
# Mac/Linux:
mv content-creation-multi-agent ~/.openclaw/workspace-main/skills/content-creation-multi-agent

# Windows (PowerShell):
Move-Item content-creation-multi-agent $env:USERPROFILE\.openclaw\workspace-main\skills\content-creation-multi-agent

# 3. 运行配置脚本
cd ~/.openclaw/workspace-main/skills/content-creation-multi-agent
bash scripts/configure-bot.sh

# 4. 重启 Gateway
openclaw gateway restart
```

---

## 📋 前置要求

- ✅ OpenClaw 已安装并运行
- ✅ 飞书授权已完成
- ✅ 飞书 Bot 有以下权限:
  - `im:message`
  - `im:message:send_as_bot`
  - `docs:doc`

---

## ⚙️ 配置说明

### 方法 1: 自动配置（推荐）

在 OpenClaw 对话中发送：
```
配置飞书机器人
```

然后按提示输入：
- 机器人名称（默认：内容创作）
- App ID 和 App Secret
- 大模型名称（默认：doubao）
- 选择要创建的 Agent

### 方法 2: 手动配置

```bash
cd ~/.openclaw/workspace-main/skills/content-creation-multi-agent
bash scripts/configure-bot.sh
```

按提示输入配置信息。

### 方法 3: 对话配置

在已经配置好的飞书机器人对话中对龙虾说：
```
配置飞书机器人
机器人名称：内容创作
飞书应用凭证：
- App ID: cli_xxx
- App Secret: xxx
大模型名称：doubao
创建对应 agent：Content Agent（内容创作）
```

---

## 🤖 自动匹配规则

| 机器人名称包含 | 自动匹配 Agent |
|---------------|---------------|
| 内容、创作、Content | Note + Content（笔记虾 + 内容创作） |
| 笔记、Note、知识 | Note（笔记虾） |
| 朋友圈、Moments、社交 | Note + Moments（笔记虾 + 朋友圈） |
| 视频、Video、导演 | Note + Video + Seedance（笔记虾 + 视频导演 + Seedance） |
| 图片、Image、设计 | Note + Image（笔记虾 + 图片生成） |
| 自媒体、运营 | Note + Content + Moments + Image |
| 其他 | Note + Content（默认） |

**重要**: 自动匹配时都会包含**第二大脑笔记虾**,确保素材提供能力。

---

## 🔄 完整工作流

```
步骤 1: 搜索素材
笔记虾，帮我搜索全网关于 AI 视频生成的最新资料
         ↓
步骤 2: 写文章
创作虾，使用笔记虾的资料写一篇 AI 视频生成教程文章
         ↓
步骤 3: 生成封面
图片虾，帮我生成 AI 视频教程的封面图
- 主题：AI 视频生成
- 风格：科技感
- 尺寸：1080x1080
- 数量：5 张
         ↓
步骤 4: 写视频脚本
视频虾，帮我写一个 AI 视频生成教程的视频脚本
- 时长：60 秒
- 风格：教学
         ↓
步骤 5: 生成 Seedance 提示词
Seedance 虾，帮我生成 AI 视频生成的 Seedance 视频提示词
- 主题：AI 视频生成教程
- 风格：科技感、教学
- 时长：60 秒
```

---

## 📁 文件结构

```
content-creation-multi-agent/
├── README.md                      # 本文档
├── SKILL.md                       # 技能详细说明
├── package.json                   # 项目配置
├── install.sh                     # Mac/Linux 安装脚本
├── install.bat                    # Windows 安装脚本
├── scripts/
│   ├── configure-bot.sh          # 配置脚本
│   ├── create-agents.sh          # Agent 创建脚本
│   └── generate-content.sh       # 内容生成脚本
├── config/
│   ├── agents.json               # Agent 配置模板
│   └── auto-match-rules.json     # 自动匹配规则
└── examples/
    └── workflow-examples.md      # 工作流示例
```

---

## 📊 配置文件

### 位置
```
~/.openclaw/workspace-main/bot-configs/bot-config_TIMESTAMP.json
```

### 示例
```json
{
  "robot_name": "内容创作",
  "app_id": "cli_xxx",
  "app_secret": "xxx",
  "model": "doubao",
  "agents": [
    {
      "name": "Note",
      "type": "第二大脑笔记虾",
      "model": "doubao-pro",
      "enabled": true
    },
    {
      "name": "Content",
      "type": "内容创作",
      "model": "doubao",
      "enabled": true
    }
  ],
  "created_at": "2026-03-17T14:00:00+08:00",
  "version": "4.0.2"
}
```

---

## 🎯 使用示例

### 示例 1: 创作文章

```
# 步骤 1: 搜索素材
笔记虾，帮我搜索全网关于 AI 视频生成的最新资料

# 步骤 2: 写文章
创作虾，使用笔记虾的资料写一篇 AI 视频生成教程文章
```

### 示例 2: 生成社交媒体内容

```
# 步骤 1: 提供素材
笔记虾，找一些关于时间管理的金句和案例

# 步骤 2: 创作朋友圈
朋友圈虾，帮我写 3 条关于时间管理的朋友圈文案
- 风格：正能量
- 长度：100 字以内
- 配图建议：3 张
```

### 示例 3: 制作视频内容

```
# 步骤 1: 研究主题
笔记虾，研究一下最近火爆的 AI 绘画技术

# 步骤 2: 写脚本
视频虾，写一个 60 秒的 AI 绘画教程视频脚本

# 步骤 3: 生成提示词
Seedance 虾，根据脚本生成 AI 视频提示词
```

---

## 🔧 故障排查

### 检查技能文件
```bash
ls -la ~/.openclaw/workspace-main/skills/content-creation-multi-agent/
```

### 检查配置文件
```bash
ls -la ~/.openclaw/workspace-main/bot-configs/
```

### 检查 Gateway 状态
```bash
openclaw status
```

### 重新配置
```bash
cd ~/.openclaw/workspace-main/skills/content-creation-multi-agent
bash scripts/configure-bot.sh
```

---

## 📚 相关资源

- **GitHub 仓库**: https://github.com/jiebao360/content-creation-multi-agent
- **OpenClaw 文档**: https://docs.openclaw.ai
- **技能市场**: https://clawhub.ai
- **问题反馈**: https://github.com/jiebao360/content-creation-multi-agent/issues

---

## 🔄 更新日志

### v4.0.2 (2026-03-17) - 路径优化版
- ✅ 修复 Windows 安装路径硬编码问题
- ✅ 统一使用 `~/.openclaw/workspace-main/skills/` 路径
- ✅ 优化跨平台安装脚本
- ✅ 完善自动匹配规则
- ✅ 添加配置文件管理

### v4.0.1 (优化版)
- ✅ 整合第二大脑笔记虾能力
- ✅ 优化 Agent 自动匹配
- ✅ 改进配置流程

### v4.0.0
- ✅ 初始版本，6 个专业化 Agent

---

## 📄 许可证

MIT License

---

<div align="center">

**🦞 让龙虾成为你的内容创作工厂!**

[🚀 立即安装](#快速安装) | [📖 查看示例](#使用示例) | [💬 问题反馈](#相关资源)

</div>
