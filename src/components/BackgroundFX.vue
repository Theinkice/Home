<!-- ============================================
     DS Diary - Background FX 1.0
     科技感背景总成：细栅格 + 双光晕 + 星链粒子 + 扫描光带 + 暗角
     - 纯 Canvas 2D，不依赖 WebGL，任何环境都不会崩
     - 粒子连线 / 鼠标牵引 / 缓慢上浮 / 呼吸闪烁
     - 页面隐藏自动暂停，DPR 上限 1.5，尊重系统减弱动效设置
     ============================================ -->
<template>
  <div class="bgfx" :class="[`bgfx--${intensity}`, { 'is-on': active }]" aria-hidden="true">
    <div class="bgfx-grid"></div>
    <div class="bgfx-glow bgfx-glow--cyan"></div>
    <div class="bgfx-glow bgfx-glow--purple"></div>
    <canvas ref="canvasRef" class="bgfx-canvas"></canvas>
    <div class="bgfx-scan"></div>
    <div class="bgfx-noise"></div>
    <div class="bgfx-vignette"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { registerBurst, unregisterBurst } from '../composables/useFx.js'

const props = defineProps({
  // normal = 主内容背景；high = 入场首屏（粒子更密、光晕更亮）
  intensity: { type: String, default: 'normal' },
  // 是否响应鼠标（首屏同样响应，让用户一进来就能拨动粒子）
  interactive: { type: Boolean, default: true }
})

const canvasRef = ref(null)
const active = ref(false)

const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
const reduced = typeof window !== 'undefined' && window.matchMedia
  ? window.matchMedia('(prefers-reduced-motion: reduce)').matches
  : false

const CYAN = '0, 212, 255'
const PURPLE = '139, 92, 246'

// 粒子连线分桶批绘：每帧最多 LINK_BUCKETS 次 stroke，替代逐线绘制
const LINK_BUCKETS = 6
const linkLines = Array.from({ length: LINK_BUCKETS }, () => [])

let ctx = null
let W = 0
let H = 0
let dots = []
let rafId = 0
let running = false
let lastTime = 0
let resizeTimer = null

// 鼠标位置（视口坐标，画布 fixed inset:0 与之重合）
let mx = -9999
let my = -9999

const high = props.intensity === 'high'
let linkDist = high ? 190 : 170
let mouseRadius = high ? 250 : 200
const DAMP_BASE = 0.94 // 外力衰减后回归自然漂移

function particleCount() {
  const base = isMobile ? 52 : 96
  return high ? Math.round(base * 1.35) : base
}

function seed() {
  const n = particleCount()
  dots = new Array(n)
  for (let i = 0; i < n; i++) {
    const baseVy = -(Math.random() * 0.12 + 0.04)
    const baseVx = (Math.random() - 0.5) * 0.14
    dots[i] = {
      x: Math.random() * W,
      y: Math.random() * H,
      r: Math.random() * 1.8 + 0.5,
      vx: baseVx,
      vy: baseVy,
      bvx: baseVx,
      bvy: baseVy,
      a: Math.random() * 0.4 + 0.22,
      tw: 0.4 + Math.random() * 0.6,
      ph: Math.random() * Math.PI * 2,
      c: Math.random() > 0.82 ? PURPLE : CYAN
    }
  }
}

function resize() {
  const canvas = canvasRef.value
  if (!canvas) return false

  const w = canvas.clientWidth || window.innerWidth
  const h = canvas.clientHeight || window.innerHeight
  if (w <= 0 || h <= 0) return false

  const dpr = Math.min(window.devicePixelRatio || 1, 1.5)
  canvas.width = Math.floor(w * dpr)
  canvas.height = Math.floor(h * dpr)

  const next = canvas.getContext('2d')
  if (!next) return false
  next.setTransform(dpr, 0, 0, dpr, 0, 0)

  ctx = next
  W = w
  H = h
  seed()
  return true
}

function draw(dt) {
  if (!ctx) return

  ctx.clearRect(0, 0, W, H)

  const n = dots.length
  const k = Math.max(0.4, Math.min(2.6, dt / 16.67))
  const damp = Math.pow(DAMP_BASE, k)
  const link2 = linkDist * linkDist
  const mr2 = mouseRadius * mouseRadius

  // ---- 粒子间连线（分桶收集，最后批量绘制）----
  for (let i = 0; i < n; i++) {
    const d = dots[i]
    for (let j = i + 1; j < n; j++) {
      const b = dots[j]
      const dx = d.x - b.x
      const dy = d.y - b.y
      const d2 = dx * dx + dy * dy
      if (d2 < link2) {
        const al = (1 - Math.sqrt(d2) / linkDist) * (high ? 0.2 : 0.16)
        const bucket = Math.min(LINK_BUCKETS - 1, (al * LINK_BUCKETS / (high ? 0.2 : 0.16)) | 0)
        const arr = linkLines[bucket]
        arr.push(d.x, d.y, b.x, b.y)
      }
    }

    // ---- 鼠标牵引：连线 + 轻微排斥 ----
    if (props.interactive) {
      const mdx = d.x - mx
      const mdy = d.y - my
      const md2 = mdx * mdx + mdy * mdy
      if (md2 < mr2) {
        const md = Math.sqrt(md2) || 1
        const strength = 1 - md / mouseRadius
        ctx.strokeStyle = `rgba(${CYAN},${(strength * 0.32).toFixed(3)})`
        ctx.lineWidth = 1
        ctx.beginPath()
        ctx.moveTo(d.x, d.y)
        ctx.lineTo(mx, my)
        ctx.stroke()
        d.vx += (mdx / md) * 0.5 * strength * k
        d.vy += (mdy / md) * 0.5 * strength * k
      }
    }
  }

  // ---- 批量绘制粒子连线（每桶一次 stroke）----
  const maxA = high ? 0.2 : 0.16
  ctx.lineWidth = 1
  for (let b = 0; b < LINK_BUCKETS; b++) {
    const arr = linkLines[b]
    if (!arr.length) continue
    ctx.strokeStyle = `rgba(${CYAN},${(((b + 0.5) / LINK_BUCKETS) * maxA).toFixed(3)})`
    ctx.beginPath()
    for (let i = 0; i < arr.length; i += 4) {
      ctx.moveTo(arr[i], arr[i + 1])
      ctx.lineTo(arr[i + 2], arr[i + 3])
    }
    ctx.stroke()
    arr.length = 0
  }

  // ---- 位置更新 + 绘制圆点 ----
  const now = performance.now()
  for (let i = 0; i < n; i++) {
    const d = dots[i]

    // 外力衰减回自然漂移速度
    d.vx = d.vx * damp + d.bvx * (1 - damp)
    d.vy = d.vy * damp + d.bvy * (1 - damp)

    d.x += d.vx * k
    d.y += d.vy * k

    // 边界循环
    if (d.y < -14) {
      d.y = H + 14
      d.x = Math.random() * W
    }
    if (d.x < -14) d.x = W + 14
    if (d.x > W + 14) d.x = -14

    const a = d.a * (0.72 + 0.28 * Math.sin(now * 0.001 * d.tw + d.ph))
    ctx.beginPath()
    ctx.arc(d.x, d.y, d.r, 0, Math.PI * 2)
    ctx.fillStyle = `rgba(${d.c},${a.toFixed(3)})`
    ctx.fill()
  }
}

function loop(now) {
  if (!running) return
  const dt = lastTime ? now - lastTime : 16.67
  lastTime = now
  try {
    draw(dt)
  } catch (err) {
    // 单帧渲染失败不中断动画循环
  }
  rafId = requestAnimationFrame(loop)
}

function start() {
  if (running) return
  running = true
  lastTime = 0
  rafId = requestAnimationFrame(loop)
}

function stop() {
  running = false
  if (rafId) cancelAnimationFrame(rafId)
  rafId = 0
}

/**
 * 粒子爆发：从 (x, y) 向外推开周围粒子（首屏点击进入、全局点击特效调用）
 */
function burst(x, y, power = 1) {
  if (!dots.length) return
  const reach = 420 * power
  const reach2 = reach * reach
  for (let i = 0; i < dots.length; i++) {
    const d = dots[i]
    const dx = d.x - x
    const dy = d.y - y
    const d2 = dx * dx + dy * dy
    if (d2 < reach2) {
      const dist = Math.sqrt(d2) || 1
      const f = (1 - dist / reach) * 8 * power
      d.vx += (dx / dist) * f
      d.vy += (dy / dist) * f
    }
  }
}

function onPointerMove(e) {
  if (e.pointerType === 'touch') return
  mx = e.clientX
  my = e.clientY
}

function onPointerLeave() {
  mx = -9999
  my = -9999
}

function onResize() {
  clearTimeout(resizeTimer)
  resizeTimer = setTimeout(() => {
    resize()
  }, 180)
}

function onVisibility() {
  if (document.hidden) stop()
  else start()
}

onMounted(() => {
  const ok = resize()
  if (!ok) return

  // 供点击特效 / 首屏调用：打散周围粒子
  registerBurst(burst)

  // 减弱动效：只画一帧静态星链，不跑循环
  if (reduced) {
    draw(16.67)
    active.value = true
    return
  }

  if (props.interactive) {
    window.addEventListener('pointermove', onPointerMove, { passive: true })
    window.addEventListener('pointerout', onPointerLeave, { passive: true })
  }
  window.addEventListener('resize', onResize, { passive: true })
  document.addEventListener('visibilitychange', onVisibility)

  start()
  requestAnimationFrame(() => { active.value = true })
})

onUnmounted(() => {
  stop()
  unregisterBurst()
  clearTimeout(resizeTimer)
  window.removeEventListener('pointermove', onPointerMove)
  window.removeEventListener('pointerout', onPointerLeave)
  window.removeEventListener('resize', onResize)
  document.removeEventListener('visibilitychange', onVisibility)
  dots = []
  ctx = null
})

defineExpose({ burst })
</script>

<style scoped lang="less">
@import '../assets/styles/variables.less';

.bgfx {
  position: fixed;
  inset: 0;
  z-index: @z-background;
  pointer-events: none;
  overflow: hidden;
  opacity: 0;
  transition: opacity 1.4s ease;
  background: radial-gradient(ellipse 130% 90% at 50% 0%, #07070e 0%, #040408 52%, #010102 100%);

  &.is-on {
    opacity: 1;
  }
}

// ---- 细栅格：缓慢斜向流动 ----
.bgfx-grid {
  position: absolute;
  inset: -12%;
  background-image:
    linear-gradient(rgba(0, 212, 255, 0.05) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0, 212, 255, 0.05) 1px, transparent 1px);
  background-size: 56px 56px;
  mask-image: radial-gradient(ellipse 85% 75% at 50% 32%, #000 18%, transparent 82%);
  -webkit-mask-image: radial-gradient(ellipse 85% 75% at 50% 32%, #000 18%, transparent 82%);
  animation: bgGridDrift 26s linear infinite;
}

// ---- 双光晕：青色 + 紫色反向漂移 ----
.bgfx-glow {
  position: absolute;
  border-radius: 50%;
  will-change: transform;

  &--cyan {
    width: 62vw;
    height: 62vw;
    top: -22vw;
    right: -16vw;
    background: radial-gradient(circle, rgba(0, 212, 255, 0.085), transparent 65%);
    animation: bgGlowDrift 30s ease-in-out infinite alternate;
  }

  &--purple {
    width: 54vw;
    height: 54vw;
    bottom: -20vw;
    left: -14vw;
    background: radial-gradient(circle, rgba(139, 92, 246, 0.09), transparent 65%);
    animation: bgGlowDrift2 38s ease-in-out infinite alternate;
  }
}

.bgfx--high .bgfx-glow--cyan {
  background: radial-gradient(circle, rgba(0, 212, 255, 0.13), transparent 65%);
}

.bgfx--high .bgfx-glow--purple {
  background: radial-gradient(circle, rgba(139, 92, 246, 0.13), transparent 65%);
}

// ---- 星链粒子画布 ----
.bgfx-canvas {
  position: absolute;
  inset: 0;
  display: block;
  width: 100%;
  height: 100%;
}

// ---- 扫描光带 ----
.bgfx-scan {
  position: absolute;
  left: 0;
  right: 0;
  height: 420px;
  top: -420px;
  background: linear-gradient(
    180deg,
    transparent,
    rgba(0, 212, 255, 0.022) 55%,
    rgba(0, 212, 255, 0.055) 92%,
    transparent
  );
  mix-blend-mode: screen;
  animation: bgScan 18s linear infinite;
}

.bgfx--high .bgfx-scan {
  animation-duration: 9s;
}

// ---- 暗角：让内容区更聚焦 ----
.bgfx-vignette {
  position: absolute;
  inset: 0;
  background: radial-gradient(
    ellipse 92% 80% at 50% 45%,
    transparent 0%,
    transparent 46%,
    rgba(0, 0, 0, 0.55) 100%
  );
}

// ---- 噪点：消除大面积渐变的色带 ----
.bgfx-noise {
  position: absolute;
  inset: 0;
  opacity: 0.028;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
  background-repeat: repeat;
  background-size: 256px 256px;
}

// ---- 动画 ----
@keyframes bgGridDrift {
  from { transform: translate3d(0, 0, 0); }
  to { transform: translate3d(-56px, -56px, 0); }
}

@keyframes bgGlowDrift {
  from { transform: translate3d(0, 0, 0); }
  to { transform: translate3d(-16vw, 20vh, 0); }
}

@keyframes bgGlowDrift2 {
  from { transform: translate3d(0, 0, 0); }
  to { transform: translate3d(14vw, -18vh, 0); }
}

@keyframes bgScan {
  from { top: -420px; }
  to { top: 100%; }
}

// ---- 响应式：移动端减弱光晕尺寸，避免性能压力 ----
@media (max-width: @breakpoint-md) {
  .bgfx-grid {
    background-size: 42px 42px;
  }

  .bgfx-scan {
    display: none;
  }
}

@media (prefers-reduced-motion: reduce) {
  .bgfx-grid,
  .bgfx-glow,
  .bgfx-scan {
    animation: none !important;
  }
}
</style>
