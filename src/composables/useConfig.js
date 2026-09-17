import { reactive } from 'vue'

// 默认配置（同步，无需 await）
const defaultConfig = {
  site: {
    title: 'DS Diary',
    description: 'A passionate sharer\'s digital home',
    favicon: '/logo.png'
  },
  background: {
    enabled: true,
    clickFx: true,
    entryIntensity: 'high'
  },
  entry: {
    enabled: true,
    logo: '/logo.png',
    title: 'DS DIARY',
    subtitle: '记录生活 · 分享热爱 · 探索世界',
    hint: '点击进入',
    sessionOnce: false,
    musicOnEnter: true
  },
  hero: {
    title: 'DS',
    subtitle: 'DIARY',
    tagline: '记录生活 · 分享热爱 · 探索世界',
    signature: 'BUILD YOUR DIGITAL WORLD.',
    logo: '/logo.png',
    typewriter: true,
    typewriterSpeed: 80,
    typewriterTexts: ['记录生活 · 分享热爱 · 探索世界', 'Building Digital Experiences', 'Code · Design · Create'],
    scrollHint: true
  },
  navigation: {
    items: [
      { name: '云页', url: 'https://web.dsriji.com/', icon: 'cloud', target: '_blank' },
      { name: '博客', url: 'http://blog.dsriji.com/', icon: 'blog', target: '_blank' },
      { name: '邮局', url: 'https://webmail.dsriji.com/', icon: 'mail', target: '_blank' },
      { name: '笔记', url: 'https://log.dsriji.com/', icon: 'note', target: '_blank' },
      { name: '导航', url: 'https://nav.dsriji.com/', icon: 'nav', target: '_blank' },
      { name: '图床', url: 'https://img.dsriji.com/', icon: 'image', target: '_blank' },
      { name: '提醒', url: 'https://sub.dsriji.com/', icon: 'bell', target: '_blank' }
    ]
  },
  music: {
    enabled: true,
    src: '/music/background.mp3',
    autoplay: false,
    loop: true,
    volume: 0.5
  },
  cursor: {
    enabled: true
  },
  footer: {
    text: 'DS Diary',
    showAuthor: false,
    showTech: true
  }
}

// 创建响应式配置（使用默认值）
const config = reactive({ ...defaultConfig })

// 异步加载 config.json 并合并（不阻塞渲染）
let configLoaded = false

function loadConfig() {
  if (configLoaded) return
  configLoaded = true

  // 相对 BASE_URL 拼接，兼容部署在子路径的情况
  fetch(`${import.meta.env.BASE_URL}config.json`)
    .then(r => {
      if (!r.ok) throw new Error('config.json ' + r.status)
      return r.json()
    })
    .then(data => {
      // 深度合并配置
      if (data.site) Object.assign(config.site, data.site)
      if (data.background) Object.assign(config.background, data.background)
      if (data.entry) Object.assign(config.entry, data.entry)
      if (data.hero) Object.assign(config.hero, data.hero)
      if (data.navigation) {
        if (data.navigation.items) config.navigation.items = data.navigation.items
      }
      if (data.music) Object.assign(config.music, data.music)
      if (data.cursor) Object.assign(config.cursor, data.cursor)
      if (data.footer) Object.assign(config.footer, data.footer)

      console.log('[DS Diary] 配置文件加载成功')
    })
    .catch(() => {
      console.log('[DS Diary] 使用默认配置')
    })
}

// 立即开始加载（非阻塞）
if (typeof window !== 'undefined') {
  loadConfig()
}

export function useConfig() {
  return { config }
}

export default useConfig
