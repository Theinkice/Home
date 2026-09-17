// ============================================
//   DS Diary - Audio Singleton
//   全局唯一 audio 实例：首屏点击 → 同步 play()，
//   规避浏览器自动播放拦截；MusicPlayer 只是 UI 控件。
// ============================================
import { ref, readonly } from 'vue'

let audioEl = null

const isPlaying = ref(false)
const isReady = ref(false)
const volume = ref(0.5)

function ensureAudio() {
  if (audioEl) return audioEl
  if (typeof window === 'undefined' || typeof window.Audio === 'undefined') return null

  audioEl = new Audio()
  audioEl.loop = true
  // preload=none：背景音乐可能很大（当前 44MB），
  // 不能让它阻塞首屏加载；用户点击进入时才边下边播
  audioEl.preload = 'none'
  audioEl.volume = volume.value

  audioEl.addEventListener('play', () => { isPlaying.value = true })
  audioEl.addEventListener('pause', () => { isPlaying.value = false })
  audioEl.addEventListener('ended', () => { isPlaying.value = false })
  audioEl.addEventListener('canplaythrough', () => { isReady.value = true })
  audioEl.addEventListener('error', () => {
    isPlaying.value = false
    console.warn('[DS Diary] 音频加载失败，请检查 public/music 目录')
  })

  return audioEl
}

// 初始化音源（不会播放）
function initAudio(src, options = {}) {
  const el = ensureAudio()
  if (!el) return null

  if (src && el.getAttribute('data-src') !== src) {
    el.setAttribute('data-src', src)
    el.src = src
    isReady.value = false
  }
  if (typeof options.loop === 'boolean') el.loop = options.loop
  if (typeof options.volume === 'number') {
    volume.value = options.volume
    el.volume = options.volume
  }
  return el
}

// 播放（.play() 为同步调用，返回 Promise 便于捕获拒绝）
function playAudio() {
  const el = ensureAudio()
  if (!el || !el.src) return Promise.resolve(false)

  const result = el.play()
  if (result === undefined) return Promise.resolve(true)

  return result.then(() => true).catch(err => {
    console.warn('[DS Diary] 播放被阻止：', err && err.name)
    isPlaying.value = false
    return false
  })
}

function pauseAudio() {
  if (audioEl) audioEl.pause()
}

function toggleAudio() {
  if (isPlaying.value) {
    pauseAudio()
    return Promise.resolve(false)
  }
  return playAudio()
}

function setVolume(v) {
  const next = Math.min(1, Math.max(0, v))
  volume.value = next
  if (audioEl) audioEl.volume = next
}

export function useAudio() {
  return {
    isPlaying: readonly(isPlaying),
    isReady: readonly(isReady),
    volume: readonly(volume),
    initAudio,
    play: playAudio,
    pause: pauseAudio,
    toggle: toggleAudio,
    setVolume
  }
}

export default useAudio
