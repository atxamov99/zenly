import { LANGUAGE_OPTIONS } from '../i18n/translations'

export default function LanguageSwitcher({ locale, onChange, theme }) {
  const isLight = theme === 'light'

  return (
    <div
      className={`inline-flex items-center gap-1 rounded-2xl border p-1 backdrop-blur-xl ${
        isLight
          ? 'border-stone-200 bg-[#faf7f3] shadow-[0_6px_14px_rgba(120,113,108,0.06)]'
          : 'border-white/15 bg-white/10 shadow-float'
      }`}
    >
      {LANGUAGE_OPTIONS.map((option) => {
        const isActive = locale === option.value

        return (
          <button
            key={option.value}
            type="button"
            onClick={() => onChange(option.value)}
            className={`rounded-xl px-3 py-2 text-xs font-bold uppercase tracking-[0.12em] transition ${
              isActive
                ? isLight
                  ? 'bg-stone-900 text-stone-50'
                  : 'bg-white text-slate-950'
                : isLight
                  ? 'text-stone-500'
                  : 'text-white/70'
            }`}
            aria-label={option.label}
            title={option.label}
          >
            {option.shortLabel}
          </button>
        )
      })}
    </div>
  )
}
