// ============================================
//   DS Diary - Entry State
//   首屏门禁状态：点击「进入」后 entered = true，
//   主内容（背景特效 / 光标 / 导航 / 音乐）才挂载。
// ============================================
import { ref } from 'vue'

const entered = ref(false)

export function useEntry() {
  function enter() {
    if (entered.value) return false
    entered.value = true
    return true
  }

  return { entered, enter }
}

export default useEntry
