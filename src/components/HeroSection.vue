<!-- ============================================
     DS Diary - Hero Section 1.0 (NOIR)
     超炫酷英雄区域 - 大Logo主视觉 + 电影级入场
     ============================================ -->
<template>
  <section class="hero" :class="{ 'is-loaded': isLoaded }">
    <!-- 主 Logo 区域（替代原来的DS大字） -->
    <div class="hero-logo-main">
      <div class="logo-container">
        <img
          src="/logo.png"
          alt="DS Diary Logo"
          class="logo-main-image"
          @load="onLogoLoad"
        />
        <div class="logo-glow-ring"></div>
        <div class="logo-particles"></div>
      </div>
    </div>

    <!-- 分隔线 -->
    <div class="hero-divider">
      <span class="divider-line"></span>
      <span class="divider-diamond"></span>
      <span class="divider-line"></span>
    </div>

    <!-- 打字机副标题 -->
    <div class="hero-description">
      <p class="typewriter-text">
        <span class="typewriter-content">{{ displayText }}</span><span class="cursor">|</span>
      </p>
    </div>

    <!-- 签名式文案（装饰化：两侧短线 + 更淡字色，与打字机拉开层次） -->
    <div class="hero-signature">
      <span class="sig-line sig-line--l" aria-hidden="true"></span>
      <span class="signature-text">{{ config.hero.signature }}</span>
      <span class="sig-line sig-line--r" aria-hidden="true"></span>
    </div>

    <!-- 滚动提示 -->
    <div class="scroll-hint" v-if="config.hero.scrollHint">
      <span class="scroll-text">SCROLL DOWN</span>
      <span class="scroll-icon">
        <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <path d="M12 5v14M5 12l7 7 7-7"/>
        </svg>
      </span>
    </div>

    <!-- SEO：视觉隐藏的主标题 -->
    <h1 class="sr-only">大叔日记 - 一个爱分享的大叔！</h1>
  </section>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useConfig } from '../composables/useConfig.js'

const { config } = useConfig()
const isLoaded = ref(false)
const currentTextIndex = ref(0)
const currentCharIndex = ref(0)
const isDeleting = ref(false)
const displayText = ref('')

// 获取打字机文本数组
const typewriterTexts = computed(() => {
  return config.hero.typewriterTexts || ['记录生活', '分享热爱', '探索世界']
})

let typeInterval = null

onMounted(() => {
  // 延迟触发加载动画
  setTimeout(() => {
    isLoaded.value = true
  }, 300)

  // 启动打字机效果
  if (config.hero.typewriter) {
    setTimeout(() => {
      startTypewriter()
    }, 1200)
  } else {
    displayText.value = typewriterTexts.value[0]
  }
})

function onLogoLoad() {
  // Logo 加载完成后可添加额外效果
}

function startTypewriter() {
  const texts = typewriterTexts.value

  typeInterval = setInterval(() => {
    const currentText = texts[currentTextIndex.value]

    if (!isDeleting.value) {
      // 打字中
      if (currentCharIndex.value < currentText.length) {
        displayText.value = currentText.substring(0, currentCharIndex.value + 1)
        currentCharIndex.value++
      } else {
        // 打完，暂停后开始删除
        isDeleting.value = true
        clearInterval(typeInterval)
        typeInterval = setInterval(() => startTypewriter(), 50)
      }
    } else {
      // 删除中
      if (currentCharIndex.value > 0) {
        displayText.value = currentText.substring(0, currentCharIndex.value - 1)
        currentCharIndex.value--
      } else {
        // 删完，切换到下一段文字
        isDeleting.value = false
        currentTextIndex.value = (currentTextIndex.value + 1) % texts.length
        clearInterval(typeInterval)
        typeInterval = setInterval(() => startTypewriter(), 100)
      }
    }
  }, isDeleting.value ? 40 : 120)
}
</script>

<style scoped lang="less">
@import '../assets/styles/variables.less';
@import '../assets/styles/animations.less';

.hero {
  position: relative;
  z-index: @z-hero;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 40px 0 24px;

  // 初始状态（用于入场动画）
  opacity: 0;
  transform: translateY(30px);
  transition: all 1.5s cubic-bezier(0.16, 1, 0.3, 1);

  &.is-loaded {
    opacity: 1;
    transform: translateY(0);
  }
}

// ---- 主 Logo 区域（核心视觉）----
.hero-logo-main {
  margin-bottom: 52px;
  animation: logoFloat 8s ease-in-out infinite;
}

.logo-container {
  position: relative;
  width: 140px;
  height: 140px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-main-image {
  width: 130px;
  height: 130px;
  object-fit: contain;
  border-radius: 20px;
  // 保持原始颜色，不做反色（因为用户LOGO本身适配暗色背景）
  filter: drop-shadow(0 0 30px rgba(0, 212, 255, 0.3));
  animation: logoPulse 4s ease-in-out infinite;
  z-index: 2;
  transition: transform 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);

  &:hover {
    transform: scale(1.08) rotate(2deg);
    filter: drop-shadow(0 0 50px rgba(0, 212, 255, 0.5));
  }
}

// Logo 光晕环
.logo-glow-ring {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 160px;
  height: 160px;
  transform: translate(-50%, -50%);
  border: 1px solid rgba(0, 212, 255, 0.15);
  border-radius: 28px;
  animation: glowRingRotate 12s linear infinite;
  pointer-events: none;

  &::before {
    content: '';
    position: absolute;
    top: -2px;
    left: -2px;
    right: -2px;
    bottom: -2px;
    border-radius: 28px;
    background: conic-gradient(
      from 0deg,
      transparent,
      rgba(0, 212, 255, 0.2),
      transparent,
      rgba(0, 212, 255, 0.1),
      transparent
    );
    animation: glowRingRotate 8s linear infinite reverse;
    mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
    mask-composite: exclude;
    padding: 2px;
  }
}

// Logo 周围粒子效果
.logo-particles {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;

  &::before,
  &::after {
    content: '';
    position: absolute;
    width: 4px;
    height: 4px;
    background: @color-accent;
    border-radius: 50%;
    box-shadow:
      0 0 10px @color-accent,
      0 0 20px @color-accent;
    animation: particleFloat 6s ease-in-out infinite;
  }

  &::before {
    top: 10%;
    left: -10%;
    animation-delay: 0s;
  }

  &::after {
    bottom: 10%;
    right: -10%;
    animation-delay: 3s;
  }
}

// ---- 分隔线 ----
.hero-divider {
  display: flex;
  align-items: center;
  gap: 16px;
  margin: 0 0 18px;
  opacity: 0;
  animation: fadeInUp 0.8s ease 1s both;
}

.divider-line {
  width: 60px;
  height: 1px;
  background: linear-gradient(90deg, transparent, @color-border-subtle);

  &:last-child {
    background: linear-gradient(90deg, @color-border-subtle, transparent);
  }
}

.divider-diamond {
  width: 6px;
  height: 6px;
  background: @color-accent;
  transform: rotate(45deg);
  animation: diamondPulse 2s ease-in-out infinite;
  box-shadow: 0 0 8px @color-accent;
}

// ---- 描述/打字机 ----
.hero-description {
  min-height: 34px;
  margin-bottom: 18px;
  opacity: 0;
  animation: fadeInUp 0.8s ease 1.2s both;
}

.typewriter-text {
  margin: 0;
  font-size: 17px;
  font-weight: @font-weight-light;
  letter-spacing: 0.14em;
  color: @color-text-secondary;
}

.typewriter-content {
  display: inline;
}

.cursor {
  display: inline-block;
  margin-left: 3px;
  color: @color-accent;
  animation: cursorBlink 1s step-end infinite;
  font-weight: @font-weight-normal;
}

// ---- 签名文案（装饰化小标签：短线 + 淡色宽字距）----
.hero-signature {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  opacity: 0;
  animation: fadeInUp 0.8s ease 1.4s both;
}

.sig-line {
  width: 32px;
  height: 1px;
  flex-shrink: 0;

  &--l {
    background: linear-gradient(90deg, transparent, rgba(0, 212, 255, 0.4));
  }

  &--r {
    background: linear-gradient(90deg, rgba(0, 212, 255, 0.4), transparent);
  }
}

.signature-text {
  font-size: 10px;
  font-weight: @font-weight-medium;
  letter-spacing: 0.42em;
  color: @color-text-quaternary;
  text-transform: uppercase;
  white-space: nowrap;
}

// ---- SEO 视觉隐藏标题 ----
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

// ---- 滚动提示（流内元素，避免与下方 NAVIGATION 重叠）----
.scroll-hint {
  margin-top: 46px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  opacity: 0;
  animation: fadeInUp 0.8s ease 2s both;
}

.scroll-text {
  font-size: 9px;
  font-weight: @font-weight-medium;
  letter-spacing: 0.35em;
  color: @color-text-tertiary;
  text-transform: uppercase;
}

.scroll-icon {
  color: @color-text-tertiary;
  animation: scrollBounce 2.5s ease-in-out infinite;
}

// ---- 响应式 ----

@media (max-width: @breakpoint-md) {
  .logo-container {
    width: 110px;
    height: 110px;
  }

  .logo-main-image {
    width: 100px;
    height: 100px;
    border-radius: 16px;
  }

  .logo-glow-ring {
    width: 130px;
    height: 130px;
    border-radius: 22px;

    &::before {
      border-radius: 22px;
    }
  }

  .typewriter-text {
    font-size: 14px;
  }

  .sig-line {
    width: 20px;
  }

  .signature-text {
    letter-spacing: 0.3em;
  }
}

@media (max-width: @breakpoint-sm) {
  .logo-container {
    width: 90px;
    height: 90px;
  }

  .logo-main-image {
    width: 82px;
    height: 82px;
    border-radius: 12px;
  }

  .logo-glow-ring {
    width: 105px;
    height: 105px;
    border-radius: 18px;

    &::before {
      border-radius: 18px;
    }
  }

  .typewriter-text {
    font-size: 13px;
    letter-spacing: 0.12em;
  }

  .hero {
    padding: @spacing-lg 0;
  }

  .scroll-hint {
    display: none;
  }
}
</style>
