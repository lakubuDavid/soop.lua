import { defineConfig, presetWind4 } from 'unocss'
import presetIcons from '@unocss/preset-icons'

export default defineConfig({
  presets: [
    presetWind4(),
    presetIcons({
      scale: 1.25,
      extraProperties: { display: 'inline-block', 'vertical-align': 'middle' },
    }),
  ],
  shortcuts: {
    'btn-primary': 'inline-flex items-center gap-2 rounded-lg bg-[var(--color-primary)] px-4 py-2 text-sm font-medium text-white hover:bg-[var(--color-primary-light)] transition-colors',
    'btn-outline': 'inline-flex items-center gap-2 rounded-lg border border-[var(--color-primary-light)]/30 px-3 py-2 text-sm font-medium hover:border-[var(--color-accent)] transition-colors',
    'card': 'rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] p-4 shadow-sm',
    'stat-label': 'text-sm font-medium text-[var(--color-muted)]',
    'stat-value': 'text-2xl font-bold text-[var(--color-primary)]',
    'table-shell': 'overflow-hidden rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)]',
    'th-base': 'px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-[var(--color-muted)]',
    'td-base': 'px-4 py-3 text-sm',
    'input-base': 'w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] px-3 py-2 text-sm focus:border-[var(--color-accent)] focus:outline-none',
  },
})
