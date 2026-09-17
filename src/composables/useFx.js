// ============================================
//   DS Diary - FX 总线 (1.0)
//   让任意组件都能触发背景粒子爆发
//   （背景层注册 burst，点击层 / 首屏调用 burstAt）
// ============================================

const bus = {
  burst: null
}

export function registerBurst(fn) {
  bus.burst = typeof fn === 'function' ? fn : null
}

export function unregisterBurst() {
  bus.burst = null
}

export function burstAt(x, y, power = 1) {
  if (!bus.burst) return
  try {
    bus.burst(x, y, power)
  } catch (err) {
    // 特效失败不影响交互
  }
}

export function useFx() {
  return { registerBurst, unregisterBurst, burstAt }
}

export default useFx
