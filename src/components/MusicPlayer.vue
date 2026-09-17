<!-- ============================================
     DS Diary - Music Player 1.0 (NOIR)
     纯 UI 控件，音频由 useAudio 全局单例持有
     播放由首屏点击（用户手势）触发，规避 autoplay 限制
     ============================================ -->
<template>
  <div class="music-player" :class="{ 'is-playing': isPlaying, 'is-visible': config.music.enabled }" v-if="config.music.enabled">
    <button
      class="play-btn"
      type="button"
      @click="toggle"
      :aria-label="isPlaying ? '暂停音乐' : '播放音乐'"
    >
      <svg v-if="!isPlaying" width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
        <polygon points="5,3 19,12 5,21"/>
      </svg>
      <svg v-else width="12" height="12" viewBox="0 0 24 24" fill="currentColor">
        <rect x="6" y="4" width="4" height="16"/>
        <rect x="14" y="4" width="4" height="16"/>
      </svg>
    </button>

    <div class="visualizer" v-if="isPlaying">
      <span class="bar" v-for="i in 5" :key="i" :style="{ animationDelay: (i * 0.1) + 's' }"></span>
    </div>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, watch } from 'vue'
import { useConfig } from '../composables/useConfig.js'
import { useAudio } from '../composables/useAudio.js'

const { config } = useConfig()
const { isPlaying, initAudio, toggle } = useAudio()

function handleKeydown(e) {
  if (e.key && e.key.toLowerCase() === 'm' && config.music.enabled) {
    // 忽略输入框内的按键
    const tag = (e.target && e.target.tagName) || ''
    if (tag === 'INPUT' || tag === 'TEXTAREA') return
    toggle()
  }
}

// 音源可能在 config.json 加载后变化
watch(() => config.music.src, src => {
  initAudio(src, { loop: config.music.loop, volume: config.music.volume })
}, { immediate: true })

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped lang="less">
@import '../assets/styles/variables.less';

.music-player {
  position: fixed;
  bottom: 24px;
  right: 24px;
  z-index: @z-music;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 18px;
  background: rgba(15, 15, 20, 0.8);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 30px;
  opacity: 0;
  animation: fadeInUp 0.8s ease 1.6s both;
  transition: border-color 0.4s ease, box-shadow 0.4s ease;

  &.is-visible {
    opacity: 1;
  }

  &:hover {
    border-color: rgba(255, 255, 255, 0.15);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
  }
}

.play-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  padding: 0;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  color: @color-text-primary;
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    background: @color-accent;
    border-color: @color-accent;
    color: #000;
    transform: scale(1.05);
  }

  &:active {
    transform: scale(0.95);
  }
}

.visualizer {
  display: flex;
  align-items: center;
  gap: 3px;
  height: 16px;
}

.bar {
  width: 3px;
  height: 100%;
  background: linear-gradient(to top, @color-accent, rgba(0, 212, 255, 0.3));
  border-radius: 2px;
  animation: visualizerBar 0.8s ease-in-out infinite;
}

// 移动端适配
@media (max-width: @breakpoint-sm) {
  .music-player {
    bottom: 16px;
    right: 16px;
    padding: 8px 14px;
    gap: 10px;
  }

  .play-btn {
    width: 26px;
    height: 26px;
  }
}
</style>
