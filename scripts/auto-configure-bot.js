#!/usr/bin/env node

/**
 * 飞书机器人自动配置脚本 v4.0.8
 * 
 * 支持在飞书对话中配置新机器人
 * 自动创建 Agent、工作空间、路由绑定
 * 自动更新 openclaw.json 并重启 Gateway
 */

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

class BotAutoConfigurator {
  constructor() {
    this.openclawConfigPath = path.join(process.env.HOME, '.openclaw', 'openclaw.json');
    this.workspaceBase = path.join(process.env.HOME, '.openclaw');
  }

  /**
   * 解析配置命令
   * 支持格式：
   * 配置飞书机器人：来合火 1 号第二大脑笔记虾
   * 飞书应用凭证：
   * App ID: cli_xxx
   * App Secret: xxx
   */
  parseConfigCommand(message) {
    const lines = message.split('\n').map(line => line.trim()).filter(line => line);
    
    const config = {
      robotName: '',
      appId: '',
      appSecret: '',
      agentId: '',
      agentName: '',
      workspace: '',
      skills: []
    };

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      
      // 解析机器人名称
      if (line.includes('配置飞书机器人：')) {
        config.robotName = line.split('配置飞书机器人：')[1].trim();
      }
      
      // 解析 App ID
      if (line.toLowerCase().includes('app id:') || line.toLowerCase().includes('app id:')) {
        config.appId = line.split(':')[1].trim();
      }
      
      // 解析 App Secret
      if (line.toLowerCase().includes('app secret:')) {
        config.appSecret = line.split(':')[1].trim();
      }
      
      // 解析创建技能
      if (line.includes('创建技能') || line.includes('Agent')) {
        const skillMatch = line.match(/创建技能\s*(.+?)(?:（|,|，|$)/);
        if (skillMatch && skillMatch[1]) {
          const skillName = skillMatch[1].trim();
          config.skills = this.parseSkills(skillName);
        }
      }
    }

    // 自动匹配 Agent ID 和名称
    if (config.robotName) {
      const match = this.autoMatchAgent(config.robotName);
      config.agentId = match.agentId;
      config.agentName = match.agentName;
      config.workspace = `~/.openclaw/workspace-${config.agentId}`;
      
      // 如果没有指定技能，使用默认技能
      if (config.skills.length === 0) {
        config.skills = match.defaultSkills;
      }
    }

    return config;
  }

  /**
   * 自动匹配 Agent
   */
  autoMatchAgent(robotName) {
    const nameLower = robotName.toLowerCase();
    
    const matchRules = [
      {
        keywords: ['笔记', '笔记虾', '第二大脑', '知识'],
        agentId: 'notes',
        agentName: '第二大脑笔记虾',
        defaultSkills: ['make-notes', 'web-search', 'file-reading']
      },
      {
        keywords: ['内容', '创作', '文章', '通用'],
        agentId: 'generic_content',
        agentName: '通用内容创作虾',
        defaultSkills: ['make-create', 'content-optimization']
      },
      {
        keywords: ['朋友圈', '社交', '媒体'],
        agentId: 'moment',
        agentName: '朋友圈创作虾',
        defaultSkills: ['make-moments']
      },
      {
        keywords: ['视频', '导演', '脚本'],
        agentId: 'video',
        agentName: '电商视频导演虾',
        defaultSkills: ['video-script', 'storyboard']
      },
      {
        keywords: ['seedance', '提示词'],
        agentId: 'seedance',
        agentName: '电商 Seedance 导演虾',
        defaultSkills: ['seedance-director', 'prompt-engineering']
      },
      {
        keywords: ['图片', '设计', '封面', '素材'],
        agentId: 'image',
        agentName: '图片素材生成虾',
        defaultSkills: ['make-image', 'image-search', 'doubao-prompt']
      },
      {
        keywords: ['工作', '助手'],
        agentId: 'work',
        agentName: '工作助手',
        defaultSkills: ['all']
      }
    ];

    for (const rule of matchRules) {
      for (const keyword of rule.keywords) {
        if (nameLower.includes(keyword.toLowerCase())) {
          return rule;
        }
      }
    }

    // 默认匹配
    return {
      agentId: 'generic_content',
      agentName: '通用内容创作虾',
      defaultSkills: ['make-create', 'content-optimization']
    };
  }

  /**
   * 解析技能名称
   */
  parseSkills(skillName) {
    const skillMap = {
      'content agent': ['make-create', 'content-optimization'],
      '内容创作': ['make-create', 'content-optimization'],
      'note agent': ['make-notes', 'web-search', 'file-reading'],
      '笔记虾': ['make-notes', 'web-search', 'file-reading'],
      'moment agent': ['make-moments'],
      '朋友圈': ['make-moments'],
      'video agent': ['video-script', 'storyboard'],
      '视频导演': ['video-script', 'storyboard'],
      'seedance agent': ['seedance-director', 'prompt-engineering'],
      'image agent': ['make-image', 'image-search', 'doubao-prompt'],
      '图片生成': ['make-image', 'image-search', 'doubao-prompt']
    };

    const skillLower = skillName.toLowerCase();
    for (const [key, skills] of Object.entries(skillMap)) {
      if (skillLower.includes(key.toLowerCase())) {
        return skills;
      }
    }

    return ['all'];
  }

  /**
   * 创建工作空间目录
   */
  async createWorkspace(agentId) {
    const workspacePath = path.join(this.workspaceBase, `workspace-${agentId}`);
    
    return new Promise((resolve, reject) => {
      if (fs.existsSync(workspacePath)) {
        console.log(`✅ 工作空间已存在：${workspacePath}`);
        resolve(workspacePath);
        return;
      }

      exec(`mkdir -p "${workspacePath}"`, (error) => {
        if (error) {
          reject(error);
          return;
        }
        console.log(`✅ 工作空间已创建：${workspacePath}`);
        resolve(workspacePath);
      });
    });
  }

  /**
   * 读取 openclaw.json
   */
  readConfig() {
    try {
      const content = fs.readFileSync(this.openclawConfigPath, 'utf-8');
      return JSON.parse(content);
    } catch (error) {
      console.error('❌ 读取配置文件失败:', error.message);
      return null;
    }
  }

  /**
   * 写入 openclaw.json
   */
  writeConfig(config) {
    try {
      const content = JSON.stringify(config, null, 2);
      fs.writeFileSync(this.openclawConfigPath, content, 'utf-8');
      console.log('✅ 配置文件已更新');
      return true;
    } catch (error) {
      console.error('❌ 写入配置文件失败:', error.message);
      return false;
    }
  }

  /**
   * 添加 Agent 配置
   */
  addAgent(config, botConfig) {
    if (!config.agents) {
      config.agents = {
        defaults: {
          model: { primary: 'ark/doubao' },
          compaction: { mode: 'safeguard' }
        },
        list: []
      };
    }

    if (!config.agents.list) {
      config.agents.list = [];
    }

    // 检查是否已存在
    const exists = config.agents.list.some(agent => agent.id === botConfig.agentId);
    if (exists) {
      console.log(`⚠️  Agent ${botConfig.agentId} 已存在，跳过添加`);
      return false;
    }

    // 添加新 Agent
    config.agents.list.push({
      id: botConfig.agentId,
      name: botConfig.agentName,
      workspace: `~/.openclaw/workspace-${botConfig.agentId}`,
      model: {
        primary: 'ark/doubao'
      },
      skills: botConfig.skills
    });

    console.log(`✅ Agent 已添加：${botConfig.agentId} (${botConfig.agentName})`);
    return true;
  }

  /**
   * 添加飞书账户配置
   */
  addFeishuAccount(config, botConfig) {
    if (!config.channels || !config.channels.feishu) {
      console.error('❌ 飞书渠道未配置');
      return false;
    }

    if (!config.channels.feishu.accounts) {
      config.channels.feishu.accounts = {};
    }

    // 检查是否已存在
    if (config.channels.feishu.accounts[botConfig.agentId]) {
      console.log(`⚠️  账户 ${botConfig.agentId} 已存在，更新配置`);
    }

    // 添加或更新账户
    config.channels.feishu.accounts[botConfig.agentId] = {
      appId: botConfig.appId,
      appSecret: botConfig.appSecret,
      botName: botConfig.robotName,
      dmPolicy: 'allowlist',
      allowFrom: ['*'],
      groupPolicy: 'open'
    };

    console.log(`✅ 飞书账户已配置：${botConfig.agentId} (${botConfig.robotName})`);
    return true;
  }

  /**
   * 添加路由绑定
   */
  addBinding(config, botConfig) {
    if (!config.bindings) {
      config.bindings = [];
    }

    // 检查是否已存在
    const exists = config.bindings.some(
      binding => binding.agentId === botConfig.agentId && 
               binding.match.accountId === botConfig.agentId
    );

    if (exists) {
      console.log(`⚠️  路由绑定已存在，跳过添加`);
      return false;
    }

    // 添加新绑定
    config.bindings.push({
      agentId: botConfig.agentId,
      match: {
        channel: 'feishu',
        accountId: botConfig.agentId
      }
    });

    console.log(`✅ 路由绑定已添加：${botConfig.agentId}`);
    return true;
  }

  /**
   * 重启 Gateway
   */
  async restartGateway() {
    return new Promise((resolve, reject) => {
      console.log('🔄 正在重启 Gateway...');
      
      exec('openclaw gateway restart', (error, stdout, stderr) => {
        if (error) {
          console.error('❌ Gateway 重启失败:', error.message);
          reject(error);
          return;
        }
        
        console.log('✅ Gateway 重启成功');
        resolve();
      });
    });
  }

  /**
   * 生成配置报告
   */
  generateReport(botConfig) {
    return `
✅ 飞书机器人配置完成！

📋 配置信息:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
机器人名称：${botConfig.robotName}
Agent ID: ${botConfig.agentId}
Agent 名称：${botConfig.agentName}
工作空间：~/.openclaw/workspace-${botConfig.agentId}
App ID: ${botConfig.appId}
技能：${botConfig.skills.join(', ')}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 已完成的配置:
✅ 创建工作空间目录
✅ 添加 Agent 配置
✅ 添加飞书账户配置
✅ 添加路由绑定
✅ 更新 openclaw.json
✅ 重启 Gateway

📱 下一步:
1. 在飞书开放平台完成应用配置
2. 配置事件订阅
3. 发布应用
4. 在飞书中搜索"${botConfig.robotName}"并测试

💡 提示:
- 确保飞书应用已配置权限：im:message, im:message:send_as_bot
- 确保事件订阅已配置：接收消息 v2.0
- 确保应用已发布
`;
  }

  /**
   * 主配置流程
   */
  async configure(message) {
    console.log('🤖 开始自动配置飞书机器人...\n');

    // 1. 解析配置命令
    const botConfig = this.parseConfigCommand(message);
    
    if (!botConfig.robotName || !botConfig.appId || !botConfig.appSecret) {
      console.error('❌ 配置信息不完整，请提供：');
      console.error('   - 机器人名称');
      console.error('   - App ID');
      console.error('   - App Secret');
      return null;
    }

    console.log(`📋 解析到的配置:`);
    console.log(`   机器人名称：${botConfig.robotName}`);
    console.log(`   Agent ID: ${botConfig.agentId}`);
    console.log(`   Agent 名称：${botConfig.agentName}`);
    console.log(`   App ID: ${botConfig.appId}`);
    console.log(`   技能：${botConfig.skills.join(', ')}`);
    console.log('');

    // 2. 创建工作空间
    await this.createWorkspace(botConfig.agentId);

    // 3. 读取并更新配置
    const config = this.readConfig();
    if (!config) {
      console.error('❌ 无法读取配置文件');
      return null;
    }

    // 4. 添加 Agent
    this.addAgent(config, botConfig);

    // 5. 添加飞书账户
    this.addFeishuAccount(config, botConfig);

    // 6. 添加路由绑定
    this.addBinding(config, botConfig);

    // 7. 写入配置
    if (!this.writeConfig(config)) {
      console.error('❌ 配置更新失败');
      return null;
    }

    // 8. 重启 Gateway
    await this.restartGateway();

    // 9. 生成报告
    const report = this.generateReport(botConfig);
    console.log(report);

    return {
      success: true,
      config: botConfig,
      report: report
    };
  }
}

// CLI 入口
async function main() {
  const args = process.argv.slice(2);
  
  if (args.includes('--help') || args.includes('-h')) {
    console.log(`
🤖 飞书机器人自动配置工具 v4.0.8

用法:
  node auto-configure-bot.js --config "<配置文本>"

配置文本格式:
  配置飞书机器人：机器人名称
  飞书应用凭证：
  App ID: cli_xxx
  App Secret: xxx
  创建技能：技能名称

示例:
  node auto-configure-bot.js --config "配置飞书机器人：来合火 1 号第二大脑笔记虾
  飞书应用凭证：
  App ID: cli_xxx
  App Secret: xxx"

  node auto-configure-bot.js --config "配置飞书机器人：工作助手
  飞书应用凭证：
  App ID: cli_work_xxx
  App Secret: work_secret
  创建技能：Content Agent"
    `);
    process.exit(0);
  }

  // 解析参数
  let configText = '';
  for (let i = 0; i < args.length; i += 2) {
    if (args[i] === '--config' && args[i + 1]) {
      configText = args[i + 1];
    }
  }

  if (!configText) {
    console.error('❌ 错误：必须提供 --config 参数');
    console.error('使用 --help 查看帮助');
    process.exit(1);
  }

  // 执行配置
  const configurator = new BotAutoConfigurator();
  try {
    const result = await configurator.configure(configText);
    if (!result) {
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ 配置失败:', error.message);
    process.exit(1);
  }
}

// 导出模块
module.exports = BotAutoConfigurator;

// 运行 CLI
if (require.main === module) {
  main().catch(console.error);
}
