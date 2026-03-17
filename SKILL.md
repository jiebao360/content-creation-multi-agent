# 🦐 内容生成多 Agent 系统 - 技能文档

> 商用级内容生成全流程系统

**版本**: v4.0.2  
**作者**: OpenClaw 来合火  
**类型**: 多 Agent 协作系统  
**难度**: ⭐⭐⭐⭐

---

## 📋 技能概述

这是一个商用级的内容生成多 Agent 系统，整合了第二大脑笔记虾的能力，提供完整的内容创作工作流。支持配置飞书机器人名称、应用凭证、大模型名称，自动匹配 6 个内容创作 Agent。

### 核心功能

- ✅ 配置飞书机器人名称（可自定义，如：内容创作）
- ✅ 配置应用凭证（App ID、App Secret）
- ✅ 配置大模型名称（可指定或自动配置）
- ✅ 自动匹配内容创作 Agent（含第二大脑笔记虾）
- ✅ 6 个专业化内容创作 Agent
- ✅ 商用内容生成全流程
- ✅ 生成本地 md 文档
- ✅ 生成飞书文档
- ✅ 一键自动安装（跨平台）

---

## 🎭 Agent 角色

### 1. Note - 第二大脑笔记虾

**职责**: 知识管理、素材提供  
**默认模型**: doubao-pro  
**推荐技能**: web-search, file-reading, knowledge-management

**能力**:
- 全网搜索素材
- 知识库管理
- 资料整理归纳
- 提供创作素材

### 2. Content - 内容创作

**职责**: 文章写作、报告、文案  
**默认模型**: doubao  
**推荐技能**: article-writer, ai-daily-news

**能力**:
- 公众号文章撰写
- 行业报告编写
- 营销文案创作
- 技术文档编写

### 3. Moments - 朋友圈创作

**职责**: 朋友圈、社交媒体  
**默认模型**: doubao  
**推荐技能**: copywriting, social-media

**能力**:
- 朋友圈文案
- 微博内容
- 小红书笔记
- 社交媒体运营

### 4. Video Director - 视频导演

**职责**: 视频脚本、分镜  
**默认模型**: doubao-pro  
**推荐技能**: video-script, storyboard

**能力**:
- 视频脚本撰写
- 分镜设计
- 视频策划
- 内容编排

### 5. Image Generator - 图片生成

**职责**: 图片搜索、豆包生成  
**默认模型**: doubao-pro  
**推荐技能**: image-search, doubao-prompt, image-generation

**能力**:
- 图片搜索
- AI 图片生成
- 封面设计
- 配图制作

### 6. Seedance Director - Seedance 导演

**职责**: Seedance 提示词  
**默认模型**: doubao-pro  
**推荐技能**: seedance-prompt, video-direction, prompt-engineering

**能力**:
- AI 视频提示词
- 视频生成指导
- 提示词工程
- 创意实现

---

## 🔧 配置说明

### 环境变量

```bash
# 飞书应用配置
FEISHU_APP_ID=cli_xxx
FEISHU_APP_SECRET=xxx

# 大模型配置
DEFAULT_MODEL=doubao
MODEL_STUDIO_API_KEY=xxx

# OpenClaw 配置
OPENCLAW_API_KEY=xxx
WORKSPACE_DIR=~/.openclaw/workspace-main
```

### 配置文件

位置：`~/.openclaw/workspace-main/bot-configs/bot-config_TIMESTAMP.json`

```json
{
  "robot_name": "内容创作",
  "app_id": "cli_xxx",
  "app_secret": "xxx",
  "model": "doubao",
  "agents": ["Note", "Content"],
  "created_at": "2026-03-17T14:00:00+08:00",
  "version": "4.0.2"
}
```

---

## 📖 使用指南

### 安装步骤

1. **运行安装脚本**
   - Mac/Linux: `curl -fsSL https://raw.githubusercontent.com/jiebao360/content-creation-multi-agent/main/install.sh | bash`
   - Windows: 运行 `install.bat`

2. **运行配置脚本**
   ```bash
   cd ~/.openclaw/workspace-main/skills/content-creation-multi-agent
   bash scripts/configure-bot.sh
   ```

3. **重启 Gateway**
   ```bash
   openclaw gateway restart
   ```

### 使用示例

#### 示例 1: 创作文章

```
# 步骤 1: 搜索素材
笔记虾，帮我搜索全网关于 AI 视频生成的最新资料

# 步骤 2: 写文章
创作虾，使用笔记虾的资料写一篇 AI 视频生成教程文章
```

#### 示例 2: 生成社交媒体内容

```
# 步骤 1: 提供素材
笔记虾，找一些关于时间管理的金句和案例

# 步骤 2: 创作朋友圈
朋友圈虾，帮我写 3 条关于时间管理的朋友圈文案
- 风格：正能量
- 长度：100 字以内
- 配图建议：3 张
```

#### 示例 3: 制作视频内容

```
# 步骤 1: 研究主题
笔记虾，研究一下最近火爆的 AI 绘画技术

# 步骤 2: 写脚本
视频虾，写一个 60 秒的 AI 绘画教程视频脚本

# 步骤 3: 生成提示词
Seedance 虾，根据脚本生成 AI 视频提示词
```

---

## 🤖 自动匹配规则

| 机器人名称包含 | 自动匹配 Agent |
|---------------|---------------|
| 内容、创作、Content | Note + Content |
| 笔记、Note、知识 | Note |
| 朋友圈、Moments、社交 | Note + Moments |
| 视频、Video、导演 | Note + Video + Seedance |
| 图片、Image、设计 | Note + Image |
| 自媒体、运营 | Note + Content + Moments + Image |
| 其他 | Note + Content（默认） |

**重要**: 自动匹配时都会包含第二大脑笔记虾，确保素材提供能力。

---

## 📁 文件结构

```
content-creation-multi-agent/
├── README.md                      # 使用说明
├── SKILL.md                       # 技能文档
├── package.json                   # 项目配置
├── install.sh                     # Mac/Linux 安装脚本
├── install.bat                    # Windows 安装脚本
├── scripts/
│   ├── configure-bot.sh          # 配置脚本
│   ├── create-agents.sh          # Agent 创建脚本
│   └── generate-content.sh       # 内容生成脚本
├── config/
│   ├── agents.json               # Agent 配置
│   └── auto-match-rules.json     # 自动匹配规则
├── examples/
│   └── workflow-examples.md      # 工作流示例
├── output/                        # 输出目录
└── logs/                          # 日志目录
```

---

## ⚠️ 注意事项

### 系统要求

- Node.js >= 18.0.0
- OpenClaw >= 1.5.0
- Git（用于克隆仓库）

### 权限要求

飞书 Bot 需要以下权限：
- `im:message`
- `im:message:send_as_bot`
- `docs:doc`

### 安全建议

- 妥善保管 App Secret
- 不要将配置文件提交到 Git
- 定期更新 API 密钥

---

## 🐛 故障排查

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

### v4.0.2 (2026-03-17)
- ✅ 修复 Windows 安装路径硬编码问题
- ✅ 统一使用 `~/.openclaw/workspace-main/skills/` 路径
- ✅ 优化跨平台安装脚本
- ✅ 完善自动匹配规则
- ✅ 添加配置文件管理

### v4.0.1
- ✅ 整合第二大脑笔记虾能力
- ✅ 优化 Agent 自动匹配
- ✅ 改进配置流程

### v4.0.0
- ✅ 初始版本，6 个专业化 Agent

---

<div align="center">

**🦞 让龙虾成为你的内容创作工厂!**

</div>
