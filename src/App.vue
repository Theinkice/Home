<!-- ============================================
     DS Diary - App 1.0
     首屏门禁 → 点击进入 → 主内容挂载
     背景体系：细栅格 + 双光晕 + 星链粒子 + 扫描光带
     ============================================ -->
<template>
  <div class="app" :class="{ 'cursor-enabled': entered && config.cursor.enabled && !isMobile }">
    <template v-if="entered">
      <!-- 背景特效总成 -->
      <BackgroundFX v-if="config.background.enabled !== false" />

      <!-- 自定义光标（桌面端） -->
      <CustomCursor />

      <!-- 全局点击特效：冲击环 + 火花 + 粒子爆发 -->
      <ClickFX v-if="config.background.clickFx !== false" />

      <!-- 主内容区 -->
      <main class="main-content">
        <HeroSection />
        <Navigation />
        <Footer />
      </main>

      <!-- 音乐播放器 -->
      <MusicPlayer />
    </template>

    <!-- 入场首屏（覆盖在最上层，自带背景特效） -->
    <EntryScreen />
  </div>
</template>

<script setup>
import { onMounted, computed, watch } from 'vue'
import { useConfig } from './composables/useConfig.js'
import { useEntry } from './composables/useEntry.js'
import EntryScreen from './components/EntryScreen.vue'
import BackgroundFX from './components/BackgroundFX.vue'
import ClickFX from './components/ClickFX.vue'
import HeroSection from './components/HeroSection.vue'
import Navigation from './components/Navigation.vue'
import MusicPlayer from './components/MusicPlayer.vue'
import CustomCursor from './components/CustomCursor.vue'
import Footer from './components/Footer.vue'

const { config } = useConfig()
const { entered } = useEntry()

const isMobile = computed(() => {
  if (typeof window === 'undefined') return false
  return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
})

function syncHead() {
  document.title = config.site.title || 'DS Diary'

  const link = document.querySelector("link[rel*='icon']") || document.createElement('link')
  link.type = 'image/x-icon'
  link.rel = 'icon'
  link.href = config.site.favicon || '/logo.png'
  document.head.appendChild(link)
}

onMounted(() => {
  syncHead()
  document.documentElement.classList.add('noir-theme')
})

// config.json 异步加载完成后同步站点信息
watch(() => config.site.title, syncHead)
</script>

<style lang="less">
@import './assets/styles/variables.less';
@import './assets/styles/global.less';
@import './assets/styles/animations.less';
@import './assets/styles/responsive.less';

.app {
  position: relative;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  overflow-x: hidden;

  // 自定义光标启用时隐藏系统光标
  &.cursor-enabled {
    cursor: none;

    a, button, [role="button"] {
      cursor: none;
    }
  }
}

.main-content {
  position: relative;
  z-index: @z-content;
  display: flex;
  flex-direction: column;
  align-items: center;
  // auto-margin 居中：内容不足时垂直居中，超高时可正常滚动（flex center 会裁掉顶部）
  & > :first-child { margin-top: auto; }
  & > :last-child { margin-bottom: auto; }
  width: 100%;
  max-width: @container-max-width;
  padding: @spacing-2xl @container-padding;
  min-height: 100vh;
  animation: fadeIn 0.8s ease both;
}
</style>
