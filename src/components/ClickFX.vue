<!-- ============================================
     DS Diary - Click FX 1.0
     全局点击特效：冲击环 + 火花迸射 + 背景粒子爆发
     与背景星链同一套视觉语言（青 / 紫）
     ============================================ -->
<template>
  <div class="clickfx" ref="layerRef" aria-hidden="true"></div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { burstAt } from '../composables/useFx.js'

const layerRef = ref(null)
const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
const reduced = typeof window !== 'undefined' && window.matchMedia
  ? window.matchMedia('(prefers-reduced-motion: reduce)').matches
  : false

function spawn(el, className, style) {
  const node = document.createElement('span')
  node.className = className
  if (style) node.style.cssText = style
  el.appendChild(node)
  node.addEventListener('animationend', () => node.remove(), { once: true })
  // 兜底清理，防止动画事件丢失导致的节点堆积
  setTimeout(() => node.remove(), 1400)
}

function onPointerDown(e) {
  const layer = layerRef.value
  if (!layer) return

  const x = e.clientX
  const y = e.clientY

  // 背景粒子被打散
  burstAt(x, y, isMobile ? 0.7 : 1)

  if (reduced) return

  // 冲击环
  spawn(layer, 'fx-ring', `left:${x}px;top:${y}px;`)

  // 火花迸射
  const count = isMobile ? 8 : 14
  for (let i = 0; i < count; i++) {
    const ang = (Math.PI * 2 * i) / count + Math.random() * 0.5
    const dist = 40 + Math.random() * 66
    const dx = (Math.cos(ang) * dist).toFixed(1)
    const dy = (Math.sin(ang) * dist).toFixed(1)
    const purple = Math.random() > 0.7 ? ' t-purple' : ''
    spawn(
      layer,
      'fx-spark' + purple,
      `left:${x}px;top:${y}px;--dx:${dx}px;--dy:${dy}px;`
    )
  }
}

onMounted(() => {
  document.addEventListener('pointerdown', onPointerDown, { passive: true })
})

onUnmounted(() => {
  document.removeEventListener('pointerdown', onPointerDown)
})
</script>

<style scoped lang="less">
@import '../assets/styles/variables.less';

.clickfx {
  position: fixed;
  inset: 0;
  z-index: @z-cursor;
  pointer-events: none;
  overflow: hidden;
}

:deep(.fx-ring) {
  position: absolute;
  width: 46px;
  height: 46px;
  margin: -23px 0 0 -23px;
  border: 1px solid rgba(0, 212, 255, 0.65);
  border-radius: 50%;
  box-shadow: 0 0 18px rgba(0, 212, 255, 0.35);
  animation: fxRing 0.72s cubic-bezier(0.22, 1, 0.36, 1) forwards;
}

:deep(.fx-spark) {
  position: absolute;
  width: 3px;
  height: 3px;
  margin: -1.5px 0 0 -1.5px;
  border-radius: 50%;
  background: @color-accent;
  box-shadow: 0 0 8px rgba(0, 212, 255, 0.9);
  animation: fxSpark 0.78s cubic-bezier(0.22, 1, 0.36, 1) forwards;

  &.t-purple {
    background: @color-accent-secondary;
    box-shadow: 0 0 8px rgba(139, 92, 246, 0.9);
  }
}

@keyframes fxRing {
  from {
    opacity: 0.9;
    transform: scale(1);
  }
  to {
    opacity: 0;
    transform: scale(6);
  }
}

@keyframes fxSpark {
  from {
    opacity: 1;
    transform: translate(0, 0) scale(1);
  }
  to {
    opacity: 0;
    transform: translate(var(--dx), var(--dy)) scale(0.3);
  }
}

@media (prefers-reduced-motion: reduce) {
  :deep(.fx-ring),
  :deep(.fx-spark) {
    display: none;
  }
}
</style>
