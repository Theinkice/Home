<!-- ============================================
     DS Diary - Footer 1.0 (NOIR)
     国际化版权信息
     ============================================ -->
<template>
  <footer class="footer" :class="{ 'is-visible': isVisible }">
    <div class="footer-content">
      <!-- 版权信息 -->
      <p class="copyright">
        &copy; {{ currentYear }} {{ config.footer.text }}. All Rights Reserved.
      </p>
      
      <!-- 技术标识 -->
      <p class="tech-badge" v-if="config.footer.showTech">
        <span class="badge-item">Vue 3</span>
        <span class="badge-separator">·</span>
        <span class="badge-item">Vite</span>
        <span class="badge-separator">·</span>
        <span class="badge-item">NOIR</span>
      </p>
    </div>
  </footer>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useConfig } from '../composables/useConfig.js'

const { config } = useConfig()
const isVisible = ref(false)

const currentYear = computed(() => new Date().getFullYear())

onMounted(() => {
  setTimeout(() => {
    isVisible.value = true
  }, 2000)
})
</script>

<style scoped lang="less">
@import '../assets/styles/variables.less';
@import '../assets/styles/animations.less';

.footer {
  position: relative;
  z-index: @z-footer;
  margin-top: auto;
  padding: @spacing-xl 0 @spacing-lg;
  opacity: 0;
  transform: translateY(20px);
  transition: all 0.8s cubic-bezier(0.16, 1, 0.3, 1);
  
  &.is-visible {
    opacity: 1;
    transform: translateY(0);
  }
}

.footer-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: @spacing-sm;
}

.copyright {
  margin: 0;
  font-size: 11px;
  font-weight: @font-weight-light;
  letter-spacing: 0.08em;
  color: @color-text-tertiary;
}

.tech-badge {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0;
  font-size: 9px;
  letter-spacing: 0.15em;
  color: @color-text-quaternary;
}

.badge-item {
  text-transform: uppercase;
}

.badge-separator {
  opacity: 0.4;
}

// 响应式
@media (max-width: @breakpoint-sm) {
  .footer {
    padding: @spacing-lg 0 @spacing-md;
  }
  
  .copyright {
    font-size: 10px;
  }
  
  .tech-badge {
    font-size: 8px;
  }
}
</style>
