<!--
  DS Diary - Entry Screen 1.0
  入场首屏：整屏点击进入主页
  - 自带完整背景特效（星链粒子 / 双光晕 / 栅格 / 扫描光带），一进站就有画面
  - 点击瞬间同步触发音乐播放（用户手势内，绕过 autoplay 限制）
  - 点击时粒子爆发 + 冲击环扩散，再淡出进入主内容
-->
<template>
  <transition name="entry">
    <div
      v-if="visible"
      ref="rootRef"
      class="entry-screen"
      :class="{ 'is-leaving': leaving }"
      role="button"
      tabindex="0"
      aria-label="点击进入主页"
      @click="handleEnter"
      @keydown.enter.prevent="handleEnter"
      @keydown.space.prevent="handleEnter"
    >
      <!-- 背景特效层（与主站同一套，首屏加强） -->
      <BackgroundFX intensity="high" />

      <!-- 外扩脉冲环 -->
      <div class="entry-rings" aria-hidden="true">
        <span class="ring r1"></span>
        <span class="ring r2"></span>
        <span class="ring r3"></span>
      </div>

      <!-- HUD 四角 -->
      <div class="entry-hud" aria-hidden="true">
        <span class="hud-cell tl">DS.SYS // DIARY</span>
        <span class="hud-cell tr">{{ clock }}</span>
        <span class="hud-cell bl">SIGNAL · OK</span>
        <span class="hud-cell br">EST. 2026</span>
      </div>

      <!-- 冲击环层（点击时注入） -->
      <div ref="shockLayer" class="entry-shock-layer" aria-hidden="true"></div>

      <div class="entry-inner">
        <div class="entry-logo-wrap">
          <div class="entry-halo"></div>
          <div class="entry-halo entry-halo--outer"></div>
          <img class="entry-logo" :src="entryCfg.logo" alt="DS Diary" draggable="false" />
        </div>

        <h1 class="entry-title">
          <span class="entry-title-main">{{ entryCfg.title }}</span>
          <span class="entry-title-sweep" aria-hidden="true"></span>
        </h1>

        <div class="entry-divider">
          <span class="line"></span>
          <span class="diamond"></span>
          <span class="line"></span>
        </div>

        <p class="entry-subtitle">{{ entryCfg.subtitle }}</p>

        <div class="entry-hint">
          <span class="hint-text">{{ entryCfg.hint }}</span>
          <span class="hint-arrow">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 5v14M5 12l7 7 7-7" />
            </svg>
          </span>
        </div>
      </div>

      <p class="entry-foot">{{ footerText }}</p>
    </div>
  </transition>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch, nextTick } from 'vue'
import { useConfig } from '../composables/useConfig.js'
import { useEntry } from '../composables/useEntry.js'
import { useAudio } from '../composables/useAudio.js'
import { burstAt } from '../composables/useFx.js'
import BackgroundFX from './BackgroundFX.vue'

const { config } = useConfig()
const { entered, enter } = useEntry()
const { initAudio, play } = useAudio()

const rootRef = ref(null)
const shockLayer = ref(null)
const visible = ref(true)
const leaving = ref(false)
const clock = ref('')
let locked = false
let clockTimer = null

const SESSION_KEY = 'ds-diary-entered'
const reduced = typeof window !== 'undefined' && window.matchMedia
  ? window.matchMedia('(prefers-reduced-motion: reduce)').matches
  : false

const entryCfg = computed(() => {
  const e = config.entry || {}
  return {
    logo: e.logo || config.site.favicon || '/logo.png',
    title: e.title || 'DS DIARY',
    subtitle: e.subtitle || config.hero.signature || '',
    hint: e.hint || '点击进入',
    sessionOnce: e.sessionOnce === true,
    musicOnEnter: e.musicOnEnter !== false
  }
})

const footerText = computed(() => config.footer.text || 'DS Diary')

// 首屏背景强度（high 让粒子更密、光晕更亮）
const bgIntensity = computed(() => {
  const b = config.background || {}
  return b.entryIntensity || 'high'
})

function tickClock() {
  const d = new Date()
  clock.value = [d.getHours(), d.getMinutes(), d.getSeconds()]
    .map(n => String(n).padStart(2, '0'))
    .join(':')
}

function startMusic() {
  if (!entryCfg.value.musicOnEnter) return
  if (!config.music.enabled) return
  if (config.music.autoplay === false) return

  // 在同一用户手势内初始化并播放
  initAudio(config.music.src, { loop: config.music.loop, volume: config.music.volume })
  play()
}

// 点击位置的冲击环扩展
function spawnShock(x, y) {
  const layer = shockLayer.value
  if (!layer || reduced) return
  for (let i = 0; i < 3; i++) {
    const ring = document.createElement('span')
    ring.className = 'shock'
    ring.style.cssText = `left:${x}px;top:${y}px;animation-delay:${i * 90}ms;`
    layer.appendChild(ring)
    ring.addEventListener('animationend', () => ring.remove(), { once: true })
    setTimeout(() => ring.remove(), 1800)
  }
}

function handleEnter() {
  if (locked) return
  locked = true

  // 1) 音乐必须在本手势内启动
  startMusic()

  // 2) 首屏特效：以屏幕中心打散粒子 + 冲击环
  const cx = window.innerWidth / 2
  const cy = window.innerHeight / 2
  burstAt(cx, cy, 1.8)
  spawnShock(cx, cy)

  try {
    if (entryCfg.value.sessionOnce) sessionStorage.setItem(SESSION_KEY, '1')
  } catch (err) {
    // 隐私模式下 sessionStorage 不可用，忽略
  }

  // 3) 让特效走一小段再进入
  leaving.value = true
  if (reduced) {
    enter()
    return
  }
  setTimeout(() => enter(), 320)
}

// 内部状态：entered 变为 true 后播放退出动画，动画结束再卸载
watch(entered, value => {
  if (value) visible.value = false
})

onMounted(async () => {
  await nextTick()
  if (rootRef.value) rootRef.value.focus({ preventScroll: true })

  // 锁定滚动
  document.body.style.overflow = 'hidden'

  tickClock()
  clockTimer = setInterval(tickClock, 1000)

  let sessionDone = false
  try {
    sessionDone = entryCfg.value.sessionOnce && sessionStorage.getItem(SESSION_KEY) === '1'
  } catch (err) {
    sessionDone = false
  }

  if (sessionDone) handleEnter()
})

// config.json 异步加载完成后可能关闭首屏
watch(() => config.entry && config.entry.enabled, value => {
  if (value === false && !locked) {
    locked = true
    enter()
  }
}, { immediate: true })

watch(visible, value => {
  if (!value) document.body.style.overflow = ''
})

onUnmounted(() => {
  document.body.style.overflow = ''
  clearInterval(clockTimer)
})
</script>

<style scoped lang="less">
@import '../assets/styles/variables.less';

.entry-screen {
  position: fixed;
  inset: 0;
  z-index: @z-overlay;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #040407;
  cursor: pointer;
  outline: none;
  overflow: hidden;
  -webkit-tap-highlight-color: transparent;
}

// ---- 外扩脉冲环：从中心向外呼吸 ----
.entry-rings {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  z-index: 1;
  pointer-events: none;

  .ring {
    position: absolute;
    top: 0;
    left: 0;
    width: 200px;
    height: 200px;
    margin: -100px 0 0 -100px;
    border: 1px solid rgba(0, 212, 255, 0.16);
    border-radius: 50%;
    animation: entryRingOut 6s cubic-bezier(0.22, 1, 0.36, 1) infinite;
  }

  .r2 {
    border-color: rgba(139, 92, 246, 0.14);
    animation-delay: 2s;
  }

  .r3 {
    border-color: rgba(0, 212, 255, 0.1);
    animation-delay: 4s;
  }
}

// ---- HUD 四角 ----
.entry-hud {
  position: absolute;
  inset: 0;
  z-index: 3;
  pointer-events: none;
  font-family: @font-family-mono;
}

.hud-cell {
  position: absolute;
  font-size: 10px;
  letter-spacing: 0.18em;
  color: @color-text-quaternary;

  &.tl { top: 22px; left: 24px; }
  &.tr { top: 22px; right: 24px; color: @color-accent; opacity: 0.75; }
  &.bl { bottom: 22px; left: 24px; }
  &.br { bottom: 22px; right: 24px; }
}

// ---- 冲击环层 ----
.entry-shock-layer {
  position: absolute;
  inset: 0;
  z-index: 4;
  pointer-events: none;
}

.shock {
  position: absolute;
  width: 60px;
  height: 60px;
  margin: -30px 0 0 -30px;
  border: 1px solid rgba(0, 212, 255, 0.7);
  border-radius: 50%;
  box-shadow: 0 0 26px rgba(0, 212, 255, 0.45);
  animation: entryShock 1.2s cubic-bezier(0.22, 1, 0.36, 1) forwards;
}

.entry-inner {
  position: relative;
  z-index: 2;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 0 @spacing-lg;
  animation: entryRise 1.2s cubic-bezier(0.16, 1, 0.3, 1) both;
}

.entry-logo-wrap {
  position: relative;
  width: 120px;
  height: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: @spacing-xl;
  transition: transform 0.5s cubic-bezier(0.16, 1, 0.3, 1);
}

.entry-logo {
  width: 110px;
  height: 110px;
  object-fit: contain;
  border-radius: 18px;
  position: relative;
  z-index: 2;
  animation: entryLogoPulse 4.5s ease-in-out infinite;
  user-select: none;
}

.entry-halo {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 150px;
  height: 150px;
  transform: translate(-50%, -50%);
  border: 1px solid rgba(0, 212, 255, 0.16);
  border-radius: 26px;
  animation: entryHaloSpin 14s linear infinite;
  pointer-events: none;

  &--outer {
    width: 190px;
    height: 190px;
    border-style: dashed;
    border-color: rgba(139, 92, 246, 0.18);
    border-radius: 34px;
    animation: entryHaloSpin 22s linear infinite reverse;
  }
}

// ---- 标题 + 扫光 ----
.entry-title {
  position: relative;
  margin: 0;
  overflow: hidden;
  font-size: 30px;
  font-weight: @font-weight-thin;
  letter-spacing: 0.32em;
  text-indent: 0.32em;
  color: @color-text-primary;
  text-transform: uppercase;
  text-shadow: 0 0 44px rgba(0, 212, 255, 0.22);
  animation: entryCalmGlow 8s ease-in-out infinite;
}

.entry-title-sweep {
  position: absolute;
  top: 0;
  bottom: 0;
  width: 60px;
  background: linear-gradient(90deg, transparent, rgba(0, 212, 255, 0.28), transparent);
  animation: entrySweep 4.5s ease-in-out infinite;
  pointer-events: none;
}

.entry-divider {
  display: flex;
  align-items: center;
  gap: 14px;
  margin: @spacing-lg 0;

  .line {
    display: block;
    width: 54px;
    height: 1px;
    background: linear-gradient(90deg, transparent, @color-border-subtle);

    &:last-child {
      background: linear-gradient(90deg, @color-border-subtle, transparent);
    }
  }

  .diamond {
    display: block;
    width: 5px;
    height: 5px;
    background: @color-accent;
    transform: rotate(45deg);
    box-shadow: 0 0 10px @color-accent;
    animation: entryDiamondPulse 2.2s ease-in-out infinite;
  }
}

.entry-subtitle {
  margin: 0;
  max-width: 86vw;
  padding: 0 16px;
  font-size: 12px;
  font-weight: @font-weight-light;
  letter-spacing: 0.22em;
  color: @color-text-tertiary;
}

.entry-hint {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  margin-top: @spacing-3xl;
  animation: entryHintFloat 2.6s ease-in-out infinite;
}

.hint-text {
  font-size: 11px;
  font-weight: @font-weight-medium;
  letter-spacing: 0.34em;
  text-indent: 0.34em;
  color: @color-text-secondary;
}

.hint-arrow {
  color: @color-accent;
  display: flex;
}

.entry-foot {
  position: absolute;
  bottom: @spacing-xl;
  left: 0;
  right: 0;
  margin: 0;
  text-align: center;
  font-size: 10px;
  letter-spacing: 0.2em;
  color: @color-text-quaternary;
  z-index: 3;
}

// ---- 点击后：内容先收拢，营造"进入"的层级感 ----
.is-leaving {
  .entry-logo-wrap {
    transform: scale(1.06);
  }

  .entry-hint {
    opacity: 0;
    transition: opacity 0.3s ease;
  }
}

// ---- 退出过渡 ----
.entry-leave-active {
  transition: opacity 0.9s ease;

  .entry-inner {
    transition: opacity 0.7s ease, transform 0.9s cubic-bezier(0.16, 1, 0.3, 1);
  }
}

.entry-leave-to {
  opacity: 0;

  .entry-inner {
    opacity: 0;
    transform: translateY(-36px) scale(0.98);
  }
}

// ---- 动画 ----
@keyframes entryRise {
  from { opacity: 0; transform: translateY(24px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes entryLogoPulse {
  0%, 100% { transform: scale(1); filter: drop-shadow(0 0 26px rgba(0, 212, 255, 0.28)); }
  50% { transform: scale(1.035); filter: drop-shadow(0 0 42px rgba(0, 212, 255, 0.48)); }
}

@keyframes entryHaloSpin {
  from { transform: translate(-50%, -50%) rotate(0deg); }
  to { transform: translate(-50%, -50%) rotate(360deg); }
}

@keyframes entryDiamondPulse {
  0%, 100% { opacity: 0.75; transform: rotate(45deg) scale(1); }
  50% { opacity: 1; transform: rotate(45deg) scale(1.35); }
}

@keyframes entryHintFloat {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(6px); }
}

@keyframes entryCalmGlow {
  0%, 100% { text-shadow: 0 0 44px rgba(0, 212, 255, 0.22); }
  50% { text-shadow: 0 0 62px rgba(0, 212, 255, 0.34); }
}

@keyframes entrySweep {
  0% { left: -60px; opacity: 0; }
  20% { opacity: 1; }
  80% { opacity: 1; }
  100% { left: 100%; opacity: 0; }
}

@keyframes entryRingOut {
  0% { transform: scale(0.5); opacity: 0; }
  15% { opacity: 0.9; }
  100% { transform: scale(4.2); opacity: 0; }
}

@keyframes entryShock {
  from { transform: scale(1); opacity: 0.85; }
  to { transform: scale(9); opacity: 0; }
}

// ---- 响应式 ----
@media (max-width: @breakpoint-sm) {
  .entry-logo-wrap {
    width: 96px;
    height: 96px;
    margin-bottom: @spacing-lg;
  }

  .entry-logo {
    width: 88px;
    height: 88px;
    border-radius: 14px;
  }

  .entry-halo {
    width: 120px;
    height: 120px;
    border-radius: 20px;

    &--outer {
      width: 152px;
      height: 152px;
      border-radius: 26px;
    }
  }

  .entry-title {
    font-size: 22px;
    letter-spacing: 0.26em;
    text-indent: 0.26em;
  }

  .entry-subtitle {
    font-size: 11px;
    letter-spacing: 0.14em;
  }

  .entry-hint {
    margin-top: @spacing-2xl;
  }

  .hud-cell {
    font-size: 9px;
    letter-spacing: 0.12em;

    &.tl { top: 16px; left: 16px; }
    &.tr { top: 16px; right: 16px; }
    &.bl { bottom: 16px; left: 16px; }
    &.br { bottom: 16px; right: 16px; }
  }

  .entry-rings .ring {
    width: 140px;
    height: 140px;
    margin: -70px 0 0 -70px;
  }
}

// 尊重系统的减弱动效设置
@media (prefers-reduced-motion: reduce) {
  .entry-inner,
  .entry-logo,
  .entry-halo,
  .entry-title,
  .entry-title-sweep,
  .entry-divider .diamond,
  .entry-hint,
  .entry-rings .ring {
    animation: none !important;
  }
}
</style>
