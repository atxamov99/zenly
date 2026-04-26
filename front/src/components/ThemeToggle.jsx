import { Moon, Sun } from 'lucide-react'

export default function ThemeToggle({ theme, onToggle, labels }) {
  const isLight = theme === 'light'
  const resolvedLabels = labels || {
    dark: 'Dark',
    light: 'Light',
    switchToDark: 'Enable dark theme',
    switchToLight: 'Enable light theme',
  }

  return (
    <button
      type="button"
      onClick={onToggle}
      className={`inline-flex items-center gap-2 rounded-2xl border px-4 py-3 text-sm font-semibold backdrop-blur-xl transition ${
        isLight
          ? 'border-stone-200 bg-[#faf7f3] text-stone-700 shadow-[0_6px_14px_rgba(120,113,108,0.06)]'
          : 'border-white/15 bg-white/10 text-white shadow-float'
      }`}
      aria-label={isLight ? resolvedLabels.switchToDark : resolvedLabels.switchToLight}
    >
      {isLight ? <Moon className="h-4 w-4" /> : <Sun className="h-4 w-4" />}
      {isLight ? resolvedLabels.dark : resolvedLabels.light}
    </button>
  )
}
