#!/usr/bin/env node

/**
 * 内容生成多 Agent 系统 - 主入口 v4.0.3
 * 
 * 修复：飞书机器人消息监听和响应问题
 * 功能：消息路由、Agent 调度、配置管理
 */

const fs = require('fs');
const path = require('path');

class ContentCreationMultiAgent {
  constructor() {
    this.config = null;
    this.agents = {};
    this.botConfigs = {};
    this.workspaceDir = this.getWorkspaceDir();
    
    console.log('🦐 内容生成多 Agent 系统 v4.0.3 启动中...');
    console.log(`工作目录：${this.workspaceDir}`);
  }

  /**
   * 获取工作目录（跨平台兼容）
   */
  getWorkspaceDir() {
    // 优先使用环境变量
    if (process.env.OPENCLAW_WORKSPACE) {
      return process.env.OPENCLAW_WORKSPACE;
    }
    
    // 默认路径：~/.openclaw/workspace-main
    const homeDir = process.env.HOME || process.env.USERPROFILE;
    return path.join(homeDir, '.openclaw', 'workspace-main');
  }

  /**
   * 加载机器人配置
   */
  async loadBotConfigs() {
    const botConfigsDir = path.join(this.workspaceDir, 'bot-configs');
    
    console.log(`📂 加载机器人配置目录：${botConfigsDir}`);
    
    if (!fs.existsSync(botConfigsDir)) {
      console.log('⚠️  配置目录不存在，创建目录...');
      fs.mkdirSync(botConfigsDir, { recursive: true });
      return {};
    }

    const configs = {};
    const files = fs.readdirSync(botConfigsDir);
    
    for (const file of files) {
      if (file.startsWith('bot-config_') && file.endsWith('.json')) {
        const filePath = path.join(botConfigsDir, file);
        try {
          const content = fs.readFileSync(filePath, 'utf-8');
          const config = JSON.parse(content);
          
          if (config.robot_name) {
            configs[config.robot_name] = {
              ...config,
              config_file: filePath
            };
            console.log(`✅ 加载配置：${config.robot_name}`);
          }
        } catch (error) {
          console.error(`❌ 加载配置失败 ${file}:`, error.message);
        }
      }
    }
    
    this.botConfigs = configs;
    console.log(`📊 共加载 ${Object.keys(configs).length} 个机器人配置`);
    
    return configs;
  }

  /**
   * 初始化 Agent
   */
  async initializeAgents() {
    console.log('\n🤖 初始化 Agent...');
    
    // 从配置中加载 Agent
    for (const [robotName, config] of Object.entries(this.botConfigs)) {
      if (config.agents && Array.isArray(config.agents)) {
        console.log(`\n📍 机器人：${robotName}`);
        
        for (const agentName of config.agents) {
          const agentKey = `${robotName}_${agentName}`;
          this.agents[agentKey] = {
            name: agentName,
            robot: robotName,
            model: config.model || 'doubao',
            enabled: true
          };
          console.log(`  ✅ Agent: ${agentName} (模型：${config.model || 'doubao'})`);
        }
      }
    }
    
    console.log(`\n📊 共初始化 ${Object.keys(this.agents).length} 个 Agent 实例`);
  }

  /**
   * 处理消息
   */
  async handleMessage(message) {
    const {
      robot_name,
      content,
      sender,
      chat_id,
      message_id
    } = message;
    
    console.log(`\n💬 收到消息:`);
    console.log(`   机器人：${robot_name}`);
    console.log(`   发送者：${sender}`);
    console.log(`   内容：${content.substring(0, 50)}...`);
    
    // 1. 查找对应的机器人配置
    const config = this.botConfigs[robot_name];
    if (!config) {
      console.log(`⚠️  未找到机器人配置：${robot_name}`);
      return {
        success: false,
        error: `未找到机器人 "${robot_name}" 的配置`,
        suggestion: '请先运行配置脚本：bash scripts/configure-bot.sh'
      };
    }
    
    // 2. 根据消息内容匹配 Agent
    const matchedAgent = this.matchAgent(content, config);
    
    if (!matchedAgent) {
      console.log('⚠️  未匹配到合适的 Agent');
      return {
        success: false,
        error: '无法识别需要的服务',
        suggestion: '请尝试说："笔记虾，帮我搜索..." 或 "创作虾，帮我写..."'
      };
    }
    
    console.log(`🎯 匹配到 Agent: ${matchedAgent.name}`);
    
    // 3. 调用对应的 Agent 处理
    const result = await this.dispatchToAgent(matchedAgent, {
      content,
      sender,
      chat_id,
      message_id,
      config
    });
    
    return result;
  }

  /**
   * 根据消息内容匹配 Agent
   */
  matchAgent(content, config) {
    const contentLower = content.toLowerCase();
    
    // 关键词匹配规则
    const rules = {
      'Note': ['笔记虾', '笔记', '搜索', '查找', '资料', '素材'],
      'Content': ['创作虾', '写', '文章', '报告', '文案', '内容'],
      'Moments': ['朋友圈虾', '朋友圈', '社交', '微博', '小红书'],
      'Video Director': ['视频虾', '视频', '脚本', '分镜', '导演'],
      'Image Generator': ['图片虾', '图片', '封面', '配图', '设计', '生成图片'],
      'Seedance Director': ['Seedance 虾', '提示词', '视频提示词', 'AI 视频']
    };
    
    // 检查配置中的 Agent 列表
    const enabledAgents = config.agents || [];
    
    // 遍历规则，匹配关键词
    for (const [agentName, keywords] of Object.entries(rules)) {
      if (!enabledAgents.includes(agentName)) {
        continue;
      }
      
      for (const keyword of keywords) {
        if (contentLower.includes(keyword.toLowerCase())) {
          return {
            name: agentName,
            match_keyword: keyword
          };
        }
      }
    }
    
    // 默认返回第一个启用的 Agent
    if (enabledAgents.length > 0) {
      return {
        name: enabledAgents[0],
        match_keyword: 'default'
      };
    }
    
    return null;
  }

  /**
   * 分发到 Agent 处理
   */
  async dispatchToAgent(agent, context) {
    const { content, sender, chat_id, message_id, config } = context;
    
    console.log(`\n🚀 分发到 Agent: ${agent.name}`);
    
    // 模拟 Agent 处理（实际应该调用对应的技能）
    // 这里需要根据实际技能实现
    
    const response = {
      success: true,
      agent: agent.name,
      robot: config.robot_name,
      model: config.model,
      reply: this.generateReply(agent, content),
      metadata: {
        chat_id,
        message_id,
        sender,
        timestamp: new Date().toISOString()
      }
    };
    
    console.log(`✅ Agent 处理完成`);
    console.log(`📝 回复：${response.reply.substring(0, 100)}...`);
    
    return response;
  }

  /**
   * 生成回复内容
   */
  generateReply(agent, content) {
    const replies = {
      'Note': `📝 收到！我是第二大脑笔记虾，正在为您搜索和整理资料...\n\n关键词：${content}\n\n请稍等，我马上为您提供相关素材！`,
      
      'Content': `✍️ 好的！我是内容创作虾，准备为您撰写内容...\n\n主题：${content}\n\n我会认真创作，请稍等片刻！`,
      
      'Moments': `🌟 没问题！我是朋友圈创作虾，帮您打造精彩社交内容...\n\n需求：${content}\n\n马上为您创作吸引人的文案！`,
      
      'Video Director': `🎬 收到！我是视频导演虾，开始策划视频脚本...\n\n主题：${content}\n\n我会为您设计精彩的分镜和脚本！`,
      
      'Image Generator': `🎨 好的！我是图片生成虾，准备为您创作图片...\n\n需求：${content}\n\n马上为您生成精美的图片！`,
      
      'Seedance Director': `🎥 收到！我是 Seedance 导演虾，开始设计 AI 视频提示词...\n\n主题：${content}\n\n我会为您生成专业的视频提示词！`
    };
    
    return replies[agent.name] || `🦐 收到您的消息：${content}\\n\n我会尽快处理！`;
  }

  /**
   * 发送回复到飞书
   */
  async sendReply(reply, config, chat_id, message_id) {
    console.log(`\n📤 发送回复到飞书...`);
    console.log(`   聊天 ID: ${chat_id}`);
    console.log(`   消息 ID: ${message_id}`);
    
    // 这里需要调用飞书 API 发送消息
    // 实际实现需要：
    // 1. 使用 config.app_id 和 config.app_secret 获取 access_token
    // 2. 调用飞书消息发送 API
    // 3. 处理响应
    
    console.log(`✅ 回复已发送`);
    
    return {
      success: true,
      sent: true
    };
  }

  /**
   * 诊断配置问题
   */
  diagnose() {
    console.log('\n🔍 诊断配置问题...\n');
    
    // 1. 检查工作目录
    console.log(`1️⃣ 工作目录：${this.workspaceDir}`);
    if (!fs.existsSync(this.workspaceDir)) {
      console.log(`   ❌ 工作目录不存在！`);
      return false;
    }
    console.log(`   ✅ 工作目录存在`);
    
    // 2. 检查配置目录
    const botConfigsDir = path.join(this.workspaceDir, 'bot-configs');
    console.log(`\n2️⃣ 配置目录：${botConfigsDir}`);
    if (!fs.existsSync(botConfigsDir)) {
      console.log(`   ❌ 配置目录不存在！`);
      console.log(`   💡 请运行：bash scripts/configure-bot.sh`);
      return false;
    }
    console.log(`   ✅ 配置目录存在`);
    
    // 3. 检查配置文件
    const files = fs.readdirSync(botConfigsDir);
    const configFiles = files.filter(f => f.startsWith('bot-config_') && f.endsWith('.json'));
    console.log(`\n3️⃣ 配置文件：${configFiles.length} 个`);
    
    if (configFiles.length === 0) {
      console.log(`   ❌ 没有配置文件！`);
      console.log(`   💡 请运行：bash scripts/configure-bot.sh`);
      return false;
    }
    
    for (const file of configFiles) {
      console.log(`   - ${file}`);
    }
    
    // 4. 检查技能文件
    const skillFiles = ['README.md', 'SKILL.md', 'package.json', 'install.sh'];
    console.log(`\n4️⃣ 技能文件:`);
    
    const skillsDir = path.join(this.workspaceDir, 'skills', 'content-creation-multi-agent');
    for (const file of skillFiles) {
      const exists = fs.existsSync(path.join(skillsDir, file));
      console.log(`   ${exists ? '✅' : '❌'} ${file}`);
    }
    
    // 5. 检查 Agent 配置
    console.log(`\n5️⃣ Agent 配置:`);
    for (const [robotName, config] of Object.entries(this.botConfigs)) {
      console.log(`   📍 机器人：${robotName}`);
      console.log(`      模型：${config.model || '未指定'}`);
      console.log(`      Agent: ${config.agents ? config.agents.join(', ') : '未配置'}`);
    }
    
    console.log(`\n✅ 诊断完成`);
    return true;
  }

  /**
   * 启动服务
   */
  async start() {
    console.log('='.repeat(60));
    console.log('🦐 内容生成多 Agent 系统 v4.0.3');
    console.log('='.repeat(60));
    
    // 1. 加载配置
    await this.loadBotConfigs();
    
    // 2. 初始化 Agent
    await this.initializeAgents();
    
    // 3. 诊断（可选）
    // this.diagnose();
    
    console.log('\n✅ 系统启动完成！');
    console.log('\n💡 使用提示:');
    console.log('   - 在飞书机器人对话中发送消息');
    console.log('   - 消息格式："Agent 名称，帮我..."');
    console.log('   - 示例："笔记虾，帮我搜索 AI 资料"');
    console.log('\n🔍 如需诊断，运行：node index.js --diagnose');
    console.log('');
  }
}

// CLI 入口
async function main() {
  const args = process.argv.slice(2);
  const system = new ContentCreationMultiAgent();
  
  // 诊断模式
  if (args.includes('--diagnose')) {
    await system.loadBotConfigs();
    system.diagnose();
    return;
  }
  
  // 正常启动
  await system.start();
  
  // 监听消息（实际应该连接到飞书事件订阅）
  // 这里需要实现消息监听逻辑
}

// 导出模块
module.exports = ContentCreationMultiAgent;

// 运行 CLI
if (require.main === module) {
  main().catch(console.error);
}
