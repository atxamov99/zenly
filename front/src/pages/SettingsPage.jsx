import { ArrowLeft, LogOut, Languages, Palette, Sparkles, UserCircle2 } from 'lucide-react'
import { Link } from 'react-router-dom'
import LanguageSwitcher from '../components/LanguageSwitcher'
import ThemeToggle from '../components/ThemeToggle'
import { LANGUAGE_OPTIONS } from '../i18n/translations'

function SectionCard({ title, description, children, isLight }) {
  return (
    <section
      className={`border p-6 backdrop-blur-2xl ${
        isLight
          ? 'border-stone-200 bg-[#fbf8f4]/88 shadow-[0_10px_22px_rgba(120,113,108,0.07)]'
          : 'border-white/15 bg-white/[0.04] shadow-float'
      }`}
    >
      <h2 className={`text-xl font-black tracking-tight ${isLight ? 'text-stone-900' : 'text-white'}`}>
        {title}
      </h2>
      <p className={`mt-2 text-sm leading-6 ${isLight ? 'text-stone-600' : 'text-white/68'}`}>
        {description}
      </p>
      <div className="mt-5">{children}</div>
    </section>
  )
}

export default function SettingsPage({
  currentUser,
  onLogout,
  theme,
  onToggleTheme,
  locale,
  onChangeLocale,
  t,
}) {
  const isLight = theme === 'light'
  const currentLanguage = LANGUAGE_OPTIONS.find((item) => item.value === locale)?.label || t('languageName')
  const themeLabels = {
    dark: t('darkTheme'),
    light: t('lightTheme'),
    switchToDark: t('switchToDarkTheme'),
    switchToLight: t('switchToLightTheme'),
  }

  return (
    <main className={`relative min-h-screen overflow-hidden ${isLight ? 'bg-[#f7f1e8] text-stone-800' : 'bg-[#08111f] text-white'}`}>
      <div className={`absolute inset-0 ${isLight ? 'bg-[linear-gradient(180deg,#faf7f3_0%,#f4efe8_48%,#eee7de_100%)]' : 'bg-[linear-gradient(180deg,#060b12_0%,#0b1521_48%,#101c2b_100%)]'}`} />
      <div className={`absolute inset-0 opacity-20 ${isLight ? '[background-image:linear-gradient(rgba(120,113,108,0.12)_1px,transparent_1px),linear-gradient(90deg,rgba(120,113,108,0.12)_1px,transparent_1px)]' : '[background-image:linear-gradient(rgba(255,255,255,0.12)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.12)_1px,transparent_1px)]'} [background-size:42px_42px]`} />

      <section className="relative z-10 mx-auto flex min-h-screen w-full max-w-5xl flex-col px-4 pb-10 pt-5">
        <div className="flex items-center justify-between gap-3">
          <Link
            to="/profile"
            className={`inline-flex h-12 w-12 items-center justify-center border backdrop-blur-xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/90 text-stone-700' : 'border-white/20 bg-white/5 text-white'}`}
            aria-label={t('profile')}
          >
            <ArrowLeft className="h-5 w-5" />
          </Link>

          <div
            className={`inline-flex items-center gap-2 border px-4 py-2.5 text-sm font-semibold backdrop-blur-xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/90 text-stone-700' : 'border-white/15 bg-white/5 text-white shadow-float'}`}
          >
            <Sparkles className={`h-4 w-4 ${isLight ? 'text-stone-400' : 'text-cyan-300'}`} />
            {t('appName')}
          </div>
        </div>

        <div className="mt-6">
          <p className={`text-xs uppercase tracking-[0.2em] ${isLight ? 'text-stone-500' : 'text-white/55'}`}>
            {t('settings')}
          </p>
          <h1 className={`mt-2 text-4xl font-black tracking-tight ${isLight ? 'text-stone-900' : 'text-white'}`}>
            {t('manageApp')}
          </h1>
          <p className={`mt-3 max-w-2xl text-sm leading-6 ${isLight ? 'text-stone-600' : 'text-white/68'}`}>
            {t('settingsDescription')}
          </p>
        </div>

        <div className="mt-6 grid gap-6">
          <SectionCard title={t('appearance')} description={t('appearanceDescription')} isLight={isLight}>
            <div className="flex items-center justify-between gap-4">
              <div className="flex items-center gap-3">
                <div className={`inline-flex h-12 w-12 items-center justify-center border ${isLight ? 'border-stone-200 bg-stone-100 text-stone-600' : 'border-white/15 bg-white/5 text-white'}`}>
                  <Palette className="h-5 w-5" />
                </div>
                <div>
                  <p className={`text-sm font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>{t('theme')}</p>
                  <p className={`text-sm ${isLight ? 'text-stone-600' : 'text-white/64'}`}>
                    {t('currentTheme', { theme: isLight ? t('lightTheme').toLowerCase() : t('darkTheme').toLowerCase() })}
                  </p>
                </div>
              </div>
              <ThemeToggle theme={theme} onToggle={onToggleTheme} labels={themeLabels} />
            </div>
          </SectionCard>

          <SectionCard title={t('language')} description={t('languageDescription')} isLight={isLight}>
            <div className="flex items-center justify-between gap-4">
              <div className="flex items-center gap-3">
                <div className={`inline-flex h-12 w-12 items-center justify-center border ${isLight ? 'border-stone-200 bg-stone-100 text-stone-600' : 'border-white/15 bg-white/5 text-white'}`}>
                  <Languages className="h-5 w-5" />
                </div>
                <div>
                  <p className={`text-sm font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>{currentLanguage}</p>
                  <p className={`text-sm ${isLight ? 'text-stone-600' : 'text-white/64'}`}>{t('languageCurrent')}</p>
                </div>
              </div>
              <LanguageSwitcher locale={locale} onChange={onChangeLocale} theme={theme} />
            </div>
          </SectionCard>

          <SectionCard title={t('profile')} description={t('profileDescription')} isLight={isLight}>
            <div className="flex items-center justify-between gap-4">
              <div className="flex items-center gap-3">
                <div className={`inline-flex h-12 w-12 items-center justify-center border ${isLight ? 'border-stone-200 bg-stone-100 text-stone-600' : 'border-white/15 bg-white/5 text-white'}`}>
                  <UserCircle2 className="h-5 w-5" />
                </div>
                <div>
                  <p className={`text-sm font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>
                    {t('profile')} @{currentUser.username}
                  </p>
                  <p className={`text-sm ${isLight ? 'text-stone-600' : 'text-white/64'}`}>{t('profileDescription')}</p>
                </div>
              </div>
              <Link
                to="/profile"
                className={`inline-flex items-center justify-center rounded-2xl px-4 py-3 text-sm font-bold ${isLight ? 'bg-stone-900 text-stone-50' : 'bg-white text-slate-950'}`}
              >
                {t('openProfile')}
              </Link>
            </div>
          </SectionCard>

          <SectionCard title={t('session')} description={t('sessionDescription')} isLight={isLight}>
            <button
              type="button"
              onClick={onLogout}
              className={`inline-flex items-center justify-center gap-2 rounded-2xl border px-4 py-3 text-sm font-bold ${isLight ? 'border-stone-200 bg-white text-stone-700' : 'border-white/15 bg-white/5 text-white'}`}
            >
              <LogOut className="h-4 w-4" />
              {t('logout')}
            </button>
          </SectionCard>
        </div>
      </section>
    </main>
  )
}
