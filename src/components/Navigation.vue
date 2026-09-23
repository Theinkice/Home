<!-- ============================================
     DS Diary - Navigation 1.0 (NOIR)
     统一导航菜单 - 所有按钮一致排布
     布局：桌面 4+3 居中 | 平板 3列 | 手机 2列
     ============================================ -->
<template>
  <nav class="navigation" :class="{ 'is-visible': isVisible }">
    <!-- 导航标题 -->
    <div class="nav-label">
      <span class="nav-label-line"></span>
      <span class="nav-label-text">NAVIGATION</span>
      <span class="nav-label-line"></span>
    </div>

    <!-- 导航网格 - 所有按钮统一 -->
    <div class="nav-grid">
      <a
        v-for="(item, index) in config.navigation.items"
        :key="index"
        :href="item.url"
        :target="item.target || '_blank'"
        :rel="item.target === '_blank' ? 'noopener noreferrer' : undefined"
        class="nav-link"
        :style="{ animationDelay: (800 + index * 80) + 'ms' }"
      >
        <!-- 图标 -->
        <span class="link-icon" v-html="getIcon(item.icon)"></span>

        <!-- 文字 -->
        <span class="link-text">{{ item.name }}</span>

        <!-- 指示箭头 -->
        <span class="link-arrow">
          <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <path d="M7 17L17 7M17 7H7M17 7V17"/>
          </svg>
        </span>

        <!-- Hover 光效 -->
        <span class="link-glow"></span>
      </a>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useConfig } from '../composables/useConfig.js'

const { config } = useConfig()
const isVisible = ref(false)

onMounted(() => {
  setTimeout(() => {
    isVisible.value = true
  }, 1000)
})

// SVG 图标库
const icons = {
  blog: `<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 19l7-7 3 3-7 7-3-3z"/><path d="M18 13l-1.5-7.5L2 2l3.5 14.5L13 18l5-5z"/><path d="M2 2l7.586 7.586"/><circle cx="11" cy="11" r="2"/></svg>`,
  cloud: `<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"/></svg>`,
  note: `<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/><polyline points="14,2 14,8 20,8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>`,
  nav: `<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="3 11 22 2 13 21 11 13 3 11"/></svg>`,
  image: `<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21,15 16,10 5,21"/></svg>`,
  bell: `<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></svg>`,
  monitor: `<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>`
}

function getIcon(name) {
  return icons[name] || icons.blog
}
</script>

<style scoped lang="less">
@import '../assets/styles/variables.less';
@import '../assets/styles/animations.less';

.navigation {
  position: relative;
  z-index: @z-nav;
  margin-top: 72px;
  opacity: 0;
  transform: translateY(20px);
  transition: all 0.8s cubic-bezier(0.16, 1, 0.3, 1);

  &.is-visible {
    opacity: 1;
    transform: translateY(0);
  }
}

// 导航标签
.nav-label {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  margin-bottom: @spacing-md;
}

.nav-label-line {
  width: 40px;
  height: 1px;
  background: linear-gradient(90deg, transparent, @color-border, transparent);
}

.nav-label-text {
  font-size: 10px;
  font-weight: @font-weight-medium;
  letter-spacing: 0.3em;
  color: @color-text-tertiary;
  text-transform: uppercase;
}

// 导航网格 - 统一按钮布局
.nav-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 10px;
  max-width: 560px;
}

// 单个导航链接 - 统一样式
.nav-link {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 10px 18px;
  font-size: 11px;
  font-weight: @font-weight-medium;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: @color-text-secondary;
  text-decoration: none;
  border: 1px solid @color-border;
  background: rgba(255, 255, 255, 0.03);
  // 不用 backdrop-filter：7 个按钮各一层 blur 合成开销大，半透明底色视觉等效
  transition: all 0.35s cubic-bezier(0.16, 1, 0.3, 1);
  overflow: hidden;
  animation: navFadeIn 0.5s ease both;
  // 统一宽度让按钮更整齐
  min-width: 120px;
  flex: 0 1 auto;

  // Hover 效果
  &:hover {
    color: @color-text-primary;
    border-color: @color-accent;
    background: rgba(0, 212, 255, 0.05);
    transform: translateY(-2px);
    box-shadow: @shadow-glow-sm;

    .link-icon {
      color: @color-accent;
      transform: scale(1.1);
    }

    .link-arrow {
      opacity: 1;
      transform: translateX(0);
    }

    .link-glow {
      opacity: 1;
    }
  }

  &:active {
    transform: translateY(0) scale(0.98);
  }
}

// 图标
.link-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  color: @color-text-tertiary;
  transition: all 0.3s ease;
  flex-shrink: 0;

  :deep(svg) {
    width: 12px;
    height: 12px;
  }
}

// 文字
.link-text {
  white-space: nowrap;
}

// 箭头
.link-arrow {
  display: flex;
  align-items: center;
  color: @color-accent;
  opacity: 0;
  transform: translateX(-6px);
  transition: all 0.3s ease;
  flex-shrink: 0;
}

// Hover 光效层
.link-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 100%;
  height: 100%;
  transform: translate(-50%, -50%) scale(0);
  background: radial-gradient(circle, rgba(0, 212, 255, 0.15), transparent 70%);
  opacity: 0;
  transition: all 0.4s ease;
  pointer-events: none;
}

// ---- 响应式布局 ----

// 平板及以下
@media (max-width: @breakpoint-lg) {
  .nav-grid {
    max-width: 440px;
    gap: 8px;
  }

  .nav-link {
    padding: 9px 14px;
    font-size: 10px;
    min-width: 110px;
  }
}

// 手机
@media (max-width: @breakpoint-sm) {
  .navigation {
    margin-top: @spacing-lg;
  }

  .nav-grid {
    max-width: 300px;
    gap: 8px;
  }

  .nav-link {
    padding: 10px 14px;
    font-size: 10px;
    flex-direction: column;
    gap: 6px;
    text-align: center;
    min-width: 100px;
  }

  .link-icon {
    order: -1;
  }

  .link-arrow {
    display: none;
  }

  .nav-label {
    margin-bottom: @spacing-sm;
  }

  .nav-label-line {
    width: 30px;
  }
}

// 超小屏
@media (max-width: @breakpoint-xs) {
  .nav-grid {
    gap: 6px;
  }

  .nav-link {
    padding: 8px 12px;
    font-size: 9px;
    min-width: 90px;
  }
}
</style>
