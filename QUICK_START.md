# 🚀 内容生成多 Agent 系统 - 快速配置指南

> 5 分钟完成飞书机器人配置，让 AI 帮你工作！

**适用版本**: v4.0.4+  
**更新时间**: 2026-03-17

---

## 📋 配置前准备

### 1. 安装技能

```bash
cd ~/.openclaw/workspace-main/skills/
git clone https://github.com/jiebao360/content-creation-multi-agent.git
cd content-creation-multi-agent
bash install.sh
```

### 2. 准备飞书开放平台账号

访问：https://open.feishu.cn/

### 3. 准备以下信息

- **飞书应用 App ID** (格式：cli_xxxxxxxxxxxxxxxx)
- **飞书应用 App Secret** (在飞书开放平台查看)
- **想创建的 Agent 类型** (内容创作/朋友圈/视频/图片等)

---

## 🎯 快速配置（3 步搞定）

### 步骤 1: 在飞书开放平台创建应用

1. 访问 https://open.feishu.cn/
2. 点击"创建应用" → "企业内部开发"
3. 填写应用信息:
   - 应用名称：`内容创作机器人`
   - 应用图标：上传一个好看的图标
4. 点击"创建"

### 步骤 2: 配置应用权限和机器人

**在应用管理页面**:

#### 配置权限
1. 点击左侧"权限管理"
2. 申请以下权限:
   - ✅ `im:message` - 读取消息
   - ✅ `im:message:send_as_bot` - 发送消息
3. 点击"申请权限"，等待审批

#### 配置机器人
1. 点击左侧"机器人"
2. 启用机器人
3. 配置:
   - 机器人名称：`创作虾`
   - 单聊：✅ 启用
   - 群聊：✅ 启用
4. 保存

#### 配置事件订阅
1. 点击左侧"事件订阅"
2. 启用事件订阅
3. 订阅事件:
   - ✅ `接收消息 v2.0`
4. 保存

#### 发布应用
1. 点击"版本管理与发布"
2. 点击"创建版本" → "发布"

### 步骤 3: 在 OpenClaw 中配置

```bash
cd ~/.openclaw/workspace-main/skills/content-creation-multi-agent

# 运行配置脚本
bash scripts/configure-bot.sh
```

**按提示输入**:
```
请输入飞书机器人名称（默认：内容创作）：内容创作
App ID（必填）：cli_xxx_your_app_id
App Secret（必填）：your_app_secret
大模型名称（默认：doubao）：doubao

选择 Agent: 直接回车（自动匹配）
```

**重启 Gateway**:
```bash
openclaw gateway restart
```

**等待 20 秒**，让 Gateway 完全重启。

---

## ✅ 测试配置

### 在飞书中测试

1. 打开飞书
2. 搜索"内容创作"或你配置的机器人名称
3. 点击进入对话
4. 发送测试消息:

```
创作虾，帮我写一篇关于 AI 发展趋势的文章
```

5. 等待回复（通常 10-30 秒）

### 如果收到回复

✅ **配置成功！** 开始使用吧！

### 如果没有回复

```bash
# 1. 运行诊断工具
cd ~/.openclaw/workspace-main/skills/content-creation-multi-agent
bash scripts/diagnose.sh

# 2. 查看日志
tail -f ~/.openclaw/logs/*.log

# 3. 检查 Gateway 状态
openclaw status

# 4. 重新配置
bash scripts/configure-bot.sh
openclaw gateway restart
```

---

## 🎭 配置多个机器人（可选）

如果你想让每个 Agent 都有独立的飞书机器人身份：

### 使用多机器人配置脚本

```bash
bash scripts/configure-multi-bot.sh
```

**选择预设模板**:
```
📋 预设的机器人配置模板:

   [1] 内容创作 - Agent: Note,Content
   [2] 朋友圈助手 - Agent: Note,Moments
   [3] 视频导演 - Agent: Note,Video Director,Seedance Director
   [4] 图片生成 - Agent: Note,Image Generator
   [5] 笔记虾 - Agent: Note
   [6] 自媒体运营 - Agent: Note,Content,Moments,Image Generator

是否使用预设模板？(y/N): y
请选择模板序号（输入多个用逗号分隔，如 1,2,3）: 1,2,3,4
```

**为每个机器人输入 App ID 和 App Secret**:
```
🔧 配置机器人：内容创作
   Agent: Note,Content
   请输入 App ID: cli_xxx_content
   请输入 App Secret: xxx_content_secret

🔧 配置机器人：朋友圈助手
   Agent: Note,Moments
   请输入 App ID: cli_xxx_moments
   请输入 App Secret: xxx_moments_secret

...
```

**配置完成后重启 Gateway**:
```bash
openclaw gateway restart
```

---

## 📚 常用 Agent 配置

### 内容创作机器人

**飞书应用名称**: 内容创作机器人  
**对应 Agent**: Content  
**测试消息**:
```
创作虾，帮我写一篇 AI 发展趋势文章
```

### 朋友圈助手

**飞书应用名称**: 朋友圈助手  
**对应 Agent**: Moments  
**测试消息**:
```
朋友圈虾，帮我写 3 条正能量文案
```

### 视频导演

**飞书应用名称**: 视频导演  
**对应 Agent**: Video Director + Seedance Director  
**测试消息**:
```
视频虾，帮我写一个 60 秒产品宣传视频脚本
```

### 图片生成助手

**飞书应用名称**: 图片生成助手  
**对应 Agent**: Image Generator  
**测试消息**:
```
图片虾，帮我生成一张科技感封面图，尺寸 1080x1080
```

### 第二大脑笔记虾

**飞书应用名称**: 第二大脑笔记虾  
**对应 Agent**: Note  
**测试消息**:
```
笔记虾，帮我搜索全网关于 AI 的最新资料
```

---

## 🐛 常见问题

### Q1: 配置后消息无响应

**解决方案**:
```bash
# 1. 重启 Gateway
openclaw gateway restart

# 2. 运行诊断
bash scripts/diagnose.sh

# 3. 查看日志
tail -f ~/.openclaw/logs/*.log
```

### Q2: 提示"未找到机器人配置"

**原因**: 配置文件未生成

**解决方案**:
```bash
# 重新运行配置脚本
bash scripts/configure-bot.sh

# 确认配置文件生成
ls -la ~/.openclaw/workspace-main/bot-configs/

# 重启 Gateway
openclaw gateway restart
```

### Q3: 飞书应用权限未审批

**解决方案**:
1. 登录飞书开放平台
2. 进入应用 → 权限管理
3. 查看权限状态
4. 联系管理员审批
5. 审批后重新发布应用

### Q4: 多个机器人配置冲突

**原因**: 机器人名称重复

**解决方案**:
- 确保每个机器人名称唯一
- 检查飞书应用名称是否重复
- 删除重复的配置文件

---

## 📖 详细文档

- **完整配置指南**: docs/MULTI_BOT_SETUP.md
- **问题排查**: docs/TROUBLESHOOTING.md
- **飞书配置**: docs/FEISHU_SETUP.md
- **技能文档**: SKILL.md

---

## 🎯 学习检查清单

配置完成后，确认：

- [ ] 飞书应用已创建并发布
- [ ] 应用权限已审批
- [ ] 事件订阅已配置
- [ ] OpenClaw 配置已完成
- [ ] Gateway 已重启
- [ ] 在飞书中测试能正常回复

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

### 相关资源
- GitHub: https://github.com/jiebao360/content-creation-multi-agent
- 飞书开放平台：https://open.feishu.cn/
- OpenClaw 文档：https://docs.openclaw.ai

---

<div align="center">

**🦞 5 分钟完成配置，让龙虾为你工作！**

配置遇到问题？查看 docs/TROUBLESHOOTING.md 或提交 Issue！

</div>
