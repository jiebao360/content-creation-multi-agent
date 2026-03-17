#!/usr/bin/env node

/**
 * 电商 Seedance 提示词生成器 v1.0
 * 
 * 专为电商视频生成设计的 AI 提示词系统
 * 支持 6 种电商视频类型
 */

const fs = require('fs');
const path = require('path');

class EcommerceSeedanceGenerator {
  constructor() {
    this.templates = {
      'product-showcase': this.productShowcaseTemplate,
      'tutorial': this.tutorialTemplate,
      'brand-story': this.brandStoryTemplate,
      'live-commerce': this.liveCommerceTemplate,
      'promotion': this.promotionTemplate,
      'testimonial': this.testimonialTemplate
    };
  }

  /**
   * 商品展示视频提示词模板
   */
  productShowcaseTemplate(options) {
    const {
      productName = '产品',
      duration = 30,
      style = '科技感',
      targetAudience = '目标受众',
      sellingPoints = [],
      scenes = [],
      music = '动感',
      brandColors = []
    } = options;

    return `Create a ${duration}-second e-commerce product showcase video for ${productName}.

Scene 1 (0-${Math.min(8, duration * 0.2)}s): Product hero shot, close-up highlighting design details, 
${style} style lighting, clean background

Scene 2 (${Math.min(8, duration * 0.2)}-${duration * 0.5}s): Demonstrate key feature - ${sellingPoints[0] || 'main feature'}, 
show in use, ${scenes[0] || 'lifestyle'} setting, user interaction

Scene 3 (${duration * 0.5}-${duration * 0.75}s): Additional features - ${sellingPoints.slice(1, 3).join(', ')}, 
animated graphics overlay, technical details highlighted

Scene 4 (${duration * 0.75}-${duration}s): Final product shot with brand elements, 
${brandColors.join(', ')} color scheme, call-to-action

Style: ${style}, professional, high-quality
Music: ${music}
Target: ${targetAudience}
Key message: ${sellingPoints.join(', ')}`;
  }

  /**
   * 使用教程视频提示词模板
   */
  tutorialTemplate(options) {
    const {
      productName = '产品',
      duration = 90,
      tutorialType = '入门',
      steps = [],
      tips = [],
      voiceover = '女声，亲切友好'
    } = options;

    let script = `Create a ${duration}-second product tutorial video for ${productName} (${tutorialType} level).\n\n`;

    script += `Intro (0-10s): Product introduction, what we'll learn, 
friendly host or clean product shot\n\n`;

    steps.forEach((step, index) => {
      const startTime = 10 + (index * ((duration - 20) / steps.length));
      const endTime = startTime + ((duration - 20) / steps.length);
      script += `Step ${index + 1} (${Math.round(startTime)}-${Math.round(endTime)}s): ${step}\n`;
    });

    script += `\nOutro (${duration - 10}-${duration}s): Summary, key tips - ${tips.join(', ')}, 
call-to-action, brand logo\n\n`;

    script += `Voiceover: ${voiceover}
Style: Clear, instructional, easy to follow
Text overlay: Step numbers, key points highlighted`;

    return script;
  }

  /**
   * 品牌宣传视频提示词模板
   */
  brandStoryTemplate(options) {
    const {
      brandName = '品牌',
      duration = 90,
      positioning = '高端',
      values = [],
      emotion = '温暖',
      visualStyle = '电影感',
      narrative = '问题 - 解决'
    } = options;

    return `Create a ${duration}-second brand story video for ${brandName}.

Opening (0-15s): ${narrative.split('-')[0]} statement - problem or current situation, 
${visualStyle} cinematography, emotional tone setting

Transition (15-25s): Moment of change or realization, 
shift in mood, ${emotion} elements introduced

Solution (25-${duration * 0.65}s): Introduce ${brandName}, 
brand values - ${values.join(', ')}, 
${positioning} positioning demonstrated through visuals

Impact (${duration * 0.65}-${duration * 0.85}s): Positive transformation, 
customer stories or lifestyle improvement, emotional payoff

Closing (${duration * 0.85}-${duration}s): Brand message and logo, 
call-to-action, memorable final shot

Visual style: ${visualStyle}
Color grading: ${positioning === '高端' ? 'Rich, sophisticated tones' : positioning === '亲民' ? 'Warm, accessible colors' : 'Brand colors'}
Music: Emotional, building to uplifting
Tone: ${emotion}, authentic`;
  }

  /**
   * 直播带货视频提示词模板
   */
  liveCommerceTemplate(options) {
    const {
      productName = '商品',
      duration = 30,
      liveTime = '直播时间',
      discount = '优惠信息',
      limitedOffer = '限时福利',
      hostStyle = '激情',
      engagement = []
    } = options;

    return `Create a ${duration}-second live streaming promo video for ${productName}.

Hook (0-${Math.min(5, duration * 0.15)}s): Bold text "${productName}", 
flash sale announcement, exciting music, vibrant colors

Offer (${Math.min(5, duration * 0.15)}-${duration * 0.5}s): Product showcase, 
${discount} animation, price comparison, value proposition

Urgency (${duration * 0.5}-${duration * 0.75}s): "${limitedOffer}" with timer animation, 
limited quantity badge, ${hostStyle} energy

Call-to-Action (${duration * 0.75}-${duration}s): Live stream info "${liveTime}", 
platform logo, "预约直播" button, ${engagement.join(', ')}

Style: High-energy, sales-focused, urgency-driven
Colors: Red and gold (promotional theme)
Music: Upbeat, exciting
Text: Large, bold, animated
Host energy: ${hostStyle}`;
  }

  /**
   * 促销活动视频提示词模板
   */
  promotionTemplate(options) {
    const {
      eventName = '促销活动',
      duration = 15,
      eventTime = '活动时间',
      discount = '促销力度',
      products = '参与商品',
      urgency = '紧迫感元素'
    } = options;

    return `Create a ${duration}-second flash sale promo video for ${eventName}.

Opening (0-${Math.min(3, duration * 0.2)}s): "${eventName}" bold text, 
festive animation, theme colors

Offer (${Math.min(3, duration * 0.2)}-${duration * 0.6}s): "${discount}" animated text, 
${products} montage, value highlights

Urgency (${duration * 0.6}-${duration * 0.85}s): "${urgency}" with countdown timer, 
limited availability, ticking clock effect

CTA (${duration * 0.85}-${duration}s): "立即抢购" button, 
dates "${eventTime}", brand logo, shop now

Style: Festive, urgent, high-impact
Colors: Theme-appropriate (red/gold for Chinese festivals)
Music: Energetic, celebratory
Animation: Dynamic text, quick transitions`;
  }

  /**
   * 用户评价视频提示词模板
   */
  testimonialTemplate(options) {
    const {
      productName = '产品',
      duration = 60,
      reviewCount = 10,
      highlights = [],
      userProfiles = [],
      trustElements = []
    } = options;

    let script = `Create a ${duration}-second user testimonial video for ${productName}.\n\n`;

    script += `Opening (0-8s): "${reviewCount}+ 用户好评" counter animation, 
5-star rating display, trust badges\n\n`;

    const testimonialDuration = (duration - 16) / Math.min(3, userProfiles.length);
    
    userProfiles.slice(0, 3).forEach((profile, index) => {
      const startTime = 8 + (index * testimonialDuration);
      const endTime = startTime + testimonialDuration;
      script += `Testimonial ${index + 1} (${Math.round(startTime)}-${Math.round(endTime)}s): ${profile}, 
real photo or video, quote "${highlights[index] || '好评'}", before/after if applicable\n`;
    });

    script += `\nStats (${duration - 16}-${duration - 8}s): Key features with icons, 
statistics, social proof\n\n`;

    script += `Closing (${duration - 8}-${duration}s): Product hero shot, 
"加入${reviewCount}+ 满意用户", CTA "立即购买"\n\n`;

    script += `Style: Authentic, trustworthy, relatable
Colors: Clean, modern
Music: Warm, positive
Elements: ${trustElements.join(', ') || 'Real photos, ratings'}`;

    return script;
  }

  /**
   * 生成提示词
   */
  generate(type, options) {
    const template = this.templates[type];
    if (!template) {
      throw new Error(`未知的视频类型：${type}`);
    }
    return template(options);
  }

  /**
   * 获取可用类型
   */
  getAvailableTypes() {
    return [
      { id: 'product-showcase', name: '商品展示视频', desc: '适合新品发布、产品推广' },
      { id: 'tutorial', name: '使用教程视频', desc: '适合教学、功能演示' },
      { id: 'brand-story', name: '品牌宣传视频', desc: '适合品牌故事、企业形象' },
      { id: 'live-commerce', name: '直播带货视频', desc: '适合直播预热、切片' },
      { id: 'promotion', name: '促销活动视频', desc: '适合节日促销、店庆' },
      { id: 'testimonial', name: '用户评价视频', desc: '适合口碑营销、社交证明' }
    ];
  }
}

// CLI 入口
async function main() {
  const args = process.argv.slice(2);
  const generator = new EcommerceSeedanceGenerator();

  if (args.includes('--help') || args.includes('-h')) {
    console.log(`
🛍️  电商 Seedance 提示词生成器 v1.0

用法:
  node ecommerce-seedance.js --type <类型> [选项]

可用类型:
  product-showcase  - 商品展示视频
  tutorial          - 使用教程视频
  brand-story       - 品牌宣传视频
  live-commerce     - 直播带货视频
  promotion         - 促销活动视频
  testimonial       - 用户评价视频

示例:
  node ecommerce-seedance.js --type product-showcase \\
    --product "智能手表" \\
    --duration 30 \\
    --style "科技感" \\
    --selling-points "心率监测，7 天续航，防水"

  node ecommerce-seedance.js --type live-commerce \\
    --product "美妆大礼包" \\
    --discount "5 折，满 299 减 100" \\
    --live-time "11 月 11 日 20:00"
    `);
    process.exit(0);
  }

  // 解析参数
  const options = {};
  for (let i = 0; i < args.length; i += 2) {
    const key = args[i].replace('--', '');
    options[key] = args[i + 1];
  }

  if (!options.type) {
    console.error('❌ 错误：必须指定 --type');
    console.error('使用 --help 查看帮助');
    process.exit(1);
  }

  // 生成提示词
  try {
    const prompt = generator.generate(options.type, options);
    console.log('\n✅ 生成的 Seedance 提示词:\n');
    console.log('='.repeat(60));
    console.log(prompt);
    console.log('='.repeat(60));
    console.log('');
  } catch (error) {
    console.error('❌ 错误:', error.message);
    process.exit(1);
  }
}

// 导出模块
module.exports = EcommerceSeedanceGenerator;

// 运行 CLI
if (require.main === module) {
  main().catch(console.error);
}
