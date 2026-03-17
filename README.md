# 🦐 内容生成多 Agent 系统

> 商用级内容生成全流程系统 - 飞书机器人自动配置

**版本**: v4.0.8  
**作者**: OpenClaw 来合火  
**GitHub**: https://github.com/jiebao360/content-creation-multi-agent

---

## ✨ 核心功能

### 飞书机器人自动配置

**在飞书对话中直接配置**:
```
配置飞书机器人：来合火 1 号第二大脑笔记虾
飞书应用凭证：
App ID: cli_xxx
App Secret: xxx
```

**自动完成**:
1. ✅ 解析配置信息
2. ✅ 智能匹配 Agent（7 种规则）
3. ✅ 创建工作空间
4. ✅ 更新 openclaw.json
5. ✅ 重启 Gateway

---

## 🚀 快速开始

### 安装

**Mac / Linux**:
```bash
curl -fsSL https://raw.githubusercontent.com/jiebao360/content-creation-multi-agent/main/install.sh | bash
```

**Windows**:
```powershell
curl -fsSL https://raw.githubusercontent.com/jiebao360/content-creation-multi-agent/main/install.bat -o install.bat
.\install.bat
```

### 配置

在飞书对话中发送配置信息，系统自动完成所有配置。

---

## 🎭 智能匹配规则

| 关键词 | Agent ID | Agent 名称 |
|--------|---------|-----------|
| 笔记/笔记虾/第二大脑 | notes | 第二大脑笔记虾 |
| 内容/创作/通用 | generic_content | 通用内容创作虾 |
| 朋友圈/社交 | moment | 朋友圈创作虾 |
| 视频/导演 | video | 电商视频导演虾 |
| Seedance/提示词 | seedance | 电商 Seedance 导演虾 |
| 图片/设计 | image | 图片素材生成虾 |
| 工作/助手 | work | 工作助手 |

---

## ⚙️ 配置规范

严格遵循官方模板：
1. 每个飞书机器人对应一个独立 Agent
2. 拥有独立的工作空间和记忆
3. dmScope: per-account-channel-peer
4. groupPolicy: open

---

## 📁 文件结构

```
content-creation-multi-agent/
├── scripts/
│   └── auto-configure-bot.js      # 自动配置脚本
├── ecommerce-seedance.js           # 电商提示词生成器
├── index.js                        # 主入口
├── install.sh                      # Mac/Linux 安装脚本
├── install.bat                     # Windows 安装脚本
├── package.json                    # 项目配置
├── skill-auto-config.json          # 技能定义
└── LICENSE                         # MIT 许可证
```

---

## 📖 使用示例

### 配置笔记虾
```
配置飞书机器人：来合火 1 号第二大脑笔记虾
飞书应用凭证：
App ID: cli_a93cff63cc789cee
App Secret: DN8oxaxAV2h0pKqykSGWIenRSvIXkzl1
```

### 配置工作助手
```
配置飞书机器人：工作助手
飞书应用凭证：
App ID: cli_xxx_work
App Secret: work_secret
创建技能：Content Agent
```

---

## 🔗 相关资源

- **GitHub**: https://github.com/jiebao360/content-creation-multi-agent
- **OpenClaw**: https://docs.openclaw.ai
- **飞书开放平台**: https://open.feishu.cn/

---

<div align="center">

**🦞 在飞书对话中直接配置，让 AI 帮你完成所有配置！**

</div>
