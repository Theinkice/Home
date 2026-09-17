<!-- ============================================
     DS Diary - Custom Cursor 1.0
     准星光标 + 平滑光环 + 丝带拖尾 + 环境光晕 + 点击音效
     - 桌面端专属，移动端自动禁用
     - 拖尾用独立 Canvas，页面隐藏自动暂停
     ============================================ -->
<template>
  <div
    class="cursor-layer"
    :class="{ 'is-visible': isVisible, 'is-hover': isHovering, 'is-down': isClicking }"
    v-if="config.cursor.enabled && !isMobile"
  >
    <canvas ref="trailRef" class="cursor-trail" aria-hidden="true"></canvas>
    <div class="cursor-aura" :style="auraStyle" aria-hidden="true"></div>
    <div class="cursor-ring" :style="ringStyle" aria-hidden="true"></div>
    <div class="cursor-dot" :style="dotStyle" aria-hidden="true"></div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
import { useConfig } from '../composables/useConfig.js'

const { config } = useConfig()

const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
const reduced = typeof window !== 'undefined' && window.matchMedia
  ? window.matchMedia('(prefers-reduced-motion: reduce)').matches
  : false

const trailRef = ref(null)
const dotPos = reactive({ x: -100, y: -100 })
const ringPos = reactive({ x: -100, y: -100 })
const auraPos = reactive({ x: -100, y: -100 })
const isHovering = ref(false)
const isClicking = ref(false)
const isVisible = ref(false)

const dotStyle = computed(() => ({ transform: `translate3d(${dotPos.x}px, ${dotPos.y}px, 0)` }))
const ringStyle = computed(() => ({ transform: `translate3d(${ringPos.x}px, ${ringPos.y}px, 0)` }))
const auraStyle = computed(() => ({ transform: `translate3d(${auraPos.x}px, ${auraPos.y}px, 0)` }))

// ---------- 拖尾画布 ----------
let ctx = null
let FW = 0
let FH = 0
let rafId = 0
let running = false
const pts = []

function sizeCanvas() {
  const canvas = trailRef.value
  if (!canvas) return
  const dpr = Math.min(window.devicePixelRatio || 1, 1.5)
  FW = window.innerWidth
  FH = window.innerHeight
  canvas.width = Math.floor(FW * dpr)
  canvas.height = Math.floor(FH * dpr)
  ctx = canvas.getContext('2d')
  if (ctx) ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
}

function drawTrail() {
  if (!ctx) return
  ctx.clearRect(0, 0, FW, FH)

  for (let i = pts.length - 1; i >= 0; i--) {
    pts[i].life -= 0.03
    if (pts[i].life <= 0) pts.splice(i, 1)
  }

  if (pts.length > 2) {
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
    for (let i = 1; i < pts.length; i++) {
      const p0 = pts[i - 1]
      const p1 = pts[i]
      const t = i / pts.length
      ctx.strokeStyle = `rgba(0, 212, 255, ${(0.55 * t * p1.life).toFixed(3)})`
      ctx.lineWidth = 5.5 * t + 0.4
      ctx.beginPath()
      ctx.moveTo(p0.x, p0.y)
      ctx.lineTo(p1.x, p1.y)
      ctx.stroke()

      if (i % 6 === 0) {
        ctx.fillStyle = `rgba(139, 92, 246, ${(0.5 * t * p1.life).toFixed(3)})`
        ctx.beginPath()
        ctx.arc(p1.x, p1.y, 2.2, 0, Math.PI * 2)
        ctx.fill()
      }
    }
  }

  // 环与光晕的平滑跟随
  ringPos.x += (dotPos.x - ringPos.x) * 0.16
  ringPos.y += (dotPos.y - ringPos.y) * 0.16
  auraPos.x += (dotPos.x - auraPos.x) * 0.08
  auraPos.y += (dotPos.y - auraPos.y) * 0.08
}

function loop() {
  if (!running) return
  drawTrail()
  rafId = requestAnimationFrame(loop)
}

function start() {
  if (running) return
  running = true
  rafId = requestAnimationFrame(loop)
}

function stop() {
  running = false
  if (rafId) cancelAnimationFrame(rafId)
  rafId = 0
}

function onVisibility() {
  if (document.hidden) stop()
  else start()
}

// ---------- 点击音效（程序化生成，无需音频文件） ----------
let audioContext = null

function playClickSound() {
  if (!audioContext) {
    try {
      const Ctx = window.AudioContext || window.webkitAudioContext
      if (!Ctx) return
      audioContext = new Ctx()
    } catch (err) {
      return
    }
  }

  const ac = audioContext
  if (ac.state === 'suspended') ac.resume()

  try {
    const osc = ac.createOscillator()
    const gain = ac.createGain()
    osc.connect(gain)
    gain.connect(ac.destination)
    osc.type = 'sine'
    osc.frequency.setValueAtTime(800, ac.currentTime)
    osc.frequency.exponentialRampToValueAtTime(400, ac.currentTime + 0.05)
    gain.gain.setValueAtTime(0.15, ac.currentTime)
    gain.gain.exponentialRampToValueAtTime(0.001, ac.currentTime + 0.08)
    osc.start(ac.currentTime)
    osc.stop(ac.currentTime + 0.08)
  } catch (err) {
    // 静默处理
  }
}

// ---------- 事件 ----------
function onMouseMove(e) {
  isVisible.value = true
  dotPos.x = e.clientX
  dotPos.y = e.clientY

  const last = pts[pts.length - 1]
  if (!last || Math.hypot(e.clientX - last.x, e.clientY - last.y) > 6) {
    pts.push({
      x: e.clientX + (Math.random() * 10 - 5),
      y: e.clientY + (Math.random() * 10 - 5),
      life: 1
    })
    if (pts.length > 26) pts.shift()
  }
}

function onMouseOver(e) {
  const target = e.target
  if (!target || !target.closest) return
  if (target.closest('a, button, [role="button"], .nav-link')) {
    isHovering.value = true
  }
}

function onMouseOut() {
  isHovering.value = false
}

function onMouseDown() {
  isClicking.value = true
  playClickSound()
}

function onMouseUp() {
  isClicking.value = false
}

function onMouseLeave() {
  isVisible.value = false
  dotPos.x = -100
  dotPos.y = -100
  ringPos.x = -100
  ringPos.y = -100
  auraPos.x = -100
  auraPos.y = -100
  pts.length = 0
}

function onResize() {
  sizeCanvas()
}

onMounted(() => {
  if (isMobile) return

  sizeCanvas()

  if (!reduced) start()
  document.addEventListener('visibilitychange', onVisibility)

  document.addEventListener('mousemove', onMouseMove, { passive: true })
  document.addEventListener('mouseover', onMouseOver, { passive: true })
  document.addEventListener('mouseout', onMouseOut, { passive: true })
  document.addEventListener('mousedown', onMouseDown, { passive: true })
  document.addEventListener('mouseup', onMouseUp, { passive: true })
  window.addEventListener('resize', onResize, { passive: true })
  document.documentElement.addEventListener('mouseleave', onMouseLeave, { passive: true })
})

onUnmounted(() => {
  if (isMobile) return

  stop()
  document.removeEventListener('visibilitychange', onVisibility)
  document.removeEventListener('mousemove', onMouseMove)
  document.removeEventListener('mouseover', onMouseOver)
  document.removeEventListener('mouseout', onMouseOut)
  document.removeEventListener('mousedown', onMouseDown)
  document.removeEventListener('mouseup', onMouseUp)
  window.removeEventListener('resize', onResize)
  document.documentElement.removeEventListener('mouseleave', onMouseLeave)

  if (audioContext) {
    try { audioContext.close() } catch (err) { /* 忽略 */ }
    audioContext = null
  }
})
</script>

<style scoped lang="less">
@import '../assets/styles/variables.less';

.cursor-layer {
  position: fixed;
  inset: 0;
  z-index: @z-cursor;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.3s ease;

  &.is-visible {
    opacity: 1;
  }
}

// ---- 丝带拖尾 ----
.cursor-trail {
  position: absolute;
  inset: 0;
  display: block;
  width: 100%;
  height: 100%;
}

// ---- 环境光晕（缓慢跟随，给光标一个柔和的场） ----
.cursor-aura {
  position: absolute;
  top: 0;
  left: 0;
  width: 380px;
  height: 380px;
  margin: -190px 0 0 -190px;
  border-radius: 50%;
  background: radial-gradient(
    circle,
    rgba(0, 212, 255, 0.09),
    rgba(139, 92, 246, 0.04) 45%,
    transparent 70%
  );
  mix-blend-mode: screen;
  will-change: transform;
}

.cursor-dot {
  position: absolute;
  top: -4px;
  left: -4px;
  width: 8px;
  height: 8px;
  background: #fff;
  border-radius: 50%;
  box-shadow: 0 0 10px rgba(0, 212, 255, 0.9);
  transition: background 0.2s, box-shadow 0.2s;
  will-change: transform;
}

// ---- 准星环：四角括号 ----
.cursor-ring {
  position: absolute;
  top: 0;
  left: 0;
  width: 38px;
  height: 38px;
  margin: -19px 0 0 -19px;
  will-change: transform;

  &::before,
  &::after {
    content: '';
    position: absolute;
    width: 11px;
    height: 11px;
    border: 1px solid rgba(255, 255, 255, 0.45);
    transition: border-color 0.3s ease, width 0.3s ease, height 0.3s ease;
  }

  &::before {
    top: 0;
    left: 0;
    border-right: 0;
    border-bottom: 0;
  }

  &::after {
    bottom: 0;
    right: 0;
    border-left: 0;
    border-top: 0;
  }
}

// ---- 悬停：准星张开 ----
.is-hover .cursor-ring {
  &::before,
  &::after {
    width: 16px;
    height: 16px;
    border-color: @color-accent;
  }
}

.is-hover .cursor-dot {
  background: @color-accent;
  box-shadow: 0 0 16px rgba(0, 212, 255, 1);
}

// ---- 按下：收紧 ----
.is-down .cursor-dot {
  background: @color-accent;
}

.is-down .cursor-ring {
  &::before,
  &::after {
    border-color: @color-accent;
  }
}

@media (prefers-reduced-motion: reduce) {
  .cursor-aura {
    display: none;
  }
}
</style>
