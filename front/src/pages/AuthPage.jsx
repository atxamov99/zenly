import { useState } from 'react'
import { Compass, LogIn, Sparkles, UserPlus } from 'lucide-react'
import LanguageSwitcher from '../components/LanguageSwitcher'
import ThemeToggle from '../components/ThemeToggle'
import { buildInitials } from '../data/zenlyContent'

function normalizeUsername(value) {
  return value.trim().toLowerCase().replace(/\s+/g, '_')
}

function createStoredUser(form) {
  const username = normalizeUsername(form.username || form.email.split('@')[0] || form.name)

  return {
    id: crypto.randomUUID(),
    name: form.name.trim(),
    username,
    email: form.email.trim().toLowerCase(),
    password: form.password,
    initials: buildInitials(form.name, username),
    coordinates: [69.2447, 41.3045],
    status: 'online',
    city: '',
    address: '',
    place: '',
    bio: '',
    avatar: '',
    setupComplete: false,
    createdAt: new Date().toISOString(),
  }
}

export default function AuthPage({
  onAuthenticate,
  users,
  theme,
  onToggleTheme,
  locale,
  onChangeLocale,
  t,
}) {
  const [mode, setMode] = useState('signin')
  const [error, setError] = useState('')
  const [form, setForm] = useState({
    name: '',
    username: '',
    email: '',
    password: '',
  })
  const isLight = theme === 'light'
  const themeLabels = {
    dark: t('darkTheme'),
    light: t('lightTheme'),
    switchToDark: t('switchToDarkTheme'),
    switchToLight: t('switchToLightTheme'),
  }

  const handleChange = (event) => {
    const { name, value } = event.target
    setForm((current) => ({ ...current, [name]: value }))
    setError('')
  }

  const handleSubmit = (event) => {
    event.preventDefault()

    const email = form.email.trim().toLowerCase()
    const username = normalizeUsername(form.username)

    if (mode === 'register') {
      if (!form.name.trim() || !email || !form.password.trim()) {
        setError(t('registerValidation'))
        return
      }

      const duplicateUser = users.find(
        (user) => user.email.toLowerCase() === email || user.username.toLowerCase() === username,
      )

      if (duplicateUser) {
        setError(t('duplicateValidation'))
        return
      }

      onAuthenticate(createStoredUser(form), 'register')
      return
    }

    const matchedUser = users.find(
      (user) =>
        user.email.toLowerCase() === email ||
        (username && user.username.toLowerCase() === username),
    )

    if (!matchedUser || matchedUser.password !== form.password) {
      setError(t('invalidCredentials'))
      return
    }

    onAuthenticate(
      matchedUser.setupComplete === undefined
        ? { ...matchedUser, setupComplete: true }
        : matchedUser,
      'signin',
    )
  }

  return (
    <main className={`relative min-h-screen overflow-hidden ${isLight ? 'bg-[#f7f1e8] text-stone-800' : 'bg-slate-950 text-white'}`}>
      <div
        className={`absolute inset-0 ${
          isLight
            ? 'bg-[radial-gradient(circle_at_15%_10%,rgba(217,119,87,0.06),transparent_32%),radial-gradient(circle_at_82%_12%,rgba(125,211,252,0.06),transparent_28%),linear-gradient(180deg,#faf7f3_0%,#f4efe8_42%,#eee7de_100%)]'
            : 'bg-[radial-gradient(circle_at_15%_10%,rgba(76,141,255,0.34),transparent_28%),radial-gradient(circle_at_82%_12%,rgba(255,67,164,0.24),transparent_22%),linear-gradient(180deg,#06101f_0%,#101b31_42%,#14254b_100%)]'
        }`}
      />
      <div
        className={`absolute inset-0 ${
          isLight
            ? 'bg-[linear-gradient(rgba(120,113,108,0.06)_1px,transparent_1px),linear-gradient(90deg,rgba(120,113,108,0.06)_1px,transparent_1px)]'
            : 'bg-[linear-gradient(rgba(255,255,255,0.04)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.04)_1px,transparent_1px)]'
        } bg-[size:52px_52px]`}
      />
      <div className={`absolute left-[-8%] top-[12%] h-64 w-64 rounded-full blur-3xl ${isLight ? 'bg-amber-100/20' : 'bg-sky-500/20'}`} />
      <div className={`absolute bottom-[10%] right-[-10%] h-72 w-72 rounded-full blur-3xl ${isLight ? 'bg-sky-100/20' : 'bg-fuchsia-500/20'}`} />

      <section className="relative z-10 mx-auto flex min-h-screen w-full max-w-6xl flex-col justify-center gap-8 px-4 py-8 lg:flex-row lg:items-center lg:gap-12">
        <div className="max-w-xl">
          <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
            <div
              className={`inline-flex items-center gap-2 rounded-2xl border px-4 py-3 text-sm font-semibold backdrop-blur-xl ${
                isLight
                  ? 'border-stone-200 bg-[#faf7f3]/96 text-stone-700 shadow-[0_8px_18px_rgba(120,113,108,0.06)]'
                  : 'border-white/15 bg-white/10 text-white/86 shadow-float'
              }`}
            >
              <Sparkles className={`h-4 w-4 ${isLight ? 'text-stone-400' : 'text-sky-300'}`} />
              {t('authBadge')}
            </div>
            <div className="flex items-center gap-3">
              <LanguageSwitcher locale={locale} onChange={onChangeLocale} theme={theme} />
              <ThemeToggle theme={theme} onToggle={onToggleTheme} labels={themeLabels} />
            </div>
          </div>

          <h1 className={`mt-6 text-5xl font-black leading-none tracking-tight sm:text-6xl ${isLight ? 'text-stone-900' : 'text-white'}`}>
            {t('authTitle')}
          </h1>
          <p className={`mt-4 max-w-lg text-base leading-7 ${isLight ? 'text-stone-600' : 'text-white/72'}`}>
            {t('authDescription')}
          </p>

          <div className="mt-8 grid gap-3 sm:grid-cols-2">
            <div className={`rounded-[1.8rem] border p-4 backdrop-blur-xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/90 shadow-[0_10px_20px_rgba(120,113,108,0.06)]' : 'border-white/15 bg-white/10 shadow-float'}`}>
              <Compass className={`h-6 w-6 ${isLight ? 'text-stone-400' : 'text-sky-300'}`} />
              <p className={`mt-3 text-lg font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>{t('authCardMapTitle')}</p>
              <p className={`mt-2 text-sm ${isLight ? 'text-stone-600' : 'text-white/68'}`}>{t('authCardMapText')}</p>
            </div>
            <div className={`rounded-[1.8rem] border p-4 backdrop-blur-xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/90 shadow-[0_10px_20px_rgba(120,113,108,0.06)]' : 'border-white/15 bg-white/10 shadow-float'}`}>
              <UserPlus className={`h-6 w-6 ${isLight ? 'text-stone-400' : 'text-fuchsia-300'}`} />
              <p className={`mt-3 text-lg font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>{t('authCardProfileTitle')}</p>
              <p className={`mt-2 text-sm ${isLight ? 'text-stone-600' : 'text-white/68'}`}>{t('authCardProfileText')}</p>
            </div>
          </div>
        </div>

        <div className={`w-full max-w-md rounded-[2rem] border p-5 backdrop-blur-xl ${isLight ? 'border-stone-200 bg-[#faf7f3]/94 shadow-[0_12px_28px_rgba(120,113,108,0.08)]' : 'border-white/15 bg-white/10 shadow-float'}`}>
          <div className={`grid grid-cols-2 rounded-2xl p-1 ${isLight ? 'bg-stone-100' : 'bg-slate-950/35'}`}>
            <button
              type="button"
              onClick={() => {
                setMode('signin')
                setError('')
              }}
              className={`rounded-[1rem] px-4 py-3 text-sm font-bold transition ${mode === 'signin' ? (isLight ? 'bg-white text-stone-900 shadow-sm' : 'bg-white text-slate-950') : isLight ? 'text-stone-500' : 'text-white/70'}`}
            >
              {t('signIn')}
            </button>
            <button
              type="button"
              onClick={() => {
                setMode('register')
                setError('')
              }}
              className={`rounded-[1rem] px-4 py-3 text-sm font-bold transition ${mode === 'register' ? (isLight ? 'bg-white text-stone-900 shadow-sm' : 'bg-white text-slate-950') : isLight ? 'text-stone-500' : 'text-white/70'}`}
            >
              {t('register')}
            </button>
          </div>

          <form className="mt-5 space-y-4" onSubmit={handleSubmit}>
            {mode === 'register' ? (
              <label className="block">
                <span className={`mb-2 block text-sm font-semibold ${isLight ? 'text-stone-700' : 'text-white/80'}`}>{t('name')}</span>
                <input
                  required
                  name="name"
                  value={form.name}
                  onChange={handleChange}
                  placeholder={t('fieldNamePlaceholder')}
                  className={`w-full rounded-2xl border px-4 py-3 outline-none placeholder:text-stone-400 ${isLight ? 'border-stone-200 bg-stone-50 text-stone-900' : 'border-white/15 bg-slate-950/35 text-white placeholder:text-white/35'}`}
                />
              </label>
            ) : null}

            <label className="block">
              <span className={`mb-2 block text-sm font-semibold ${isLight ? 'text-stone-700' : 'text-white/80'}`}>{t('username')}</span>
              <input
                name="username"
                value={form.username}
                onChange={handleChange}
                placeholder={t('fieldUsernamePlaceholder')}
                className={`w-full rounded-2xl border px-4 py-3 outline-none placeholder:text-stone-400 ${isLight ? 'border-stone-200 bg-stone-50 text-stone-900' : 'border-white/15 bg-slate-950/35 text-white placeholder:text-white/35'}`}
              />
            </label>

            <label className="block">
              <span className={`mb-2 block text-sm font-semibold ${isLight ? 'text-stone-700' : 'text-white/80'}`}>{t('email')}</span>
              <input
                required
                name="email"
                type="email"
                value={form.email}
                onChange={handleChange}
                placeholder={t('fieldEmailPlaceholder')}
                className={`w-full rounded-2xl border px-4 py-3 outline-none placeholder:text-stone-400 ${isLight ? 'border-stone-200 bg-stone-50 text-stone-900' : 'border-white/15 bg-slate-950/35 text-white placeholder:text-white/35'}`}
              />
            </label>

            <label className="block">
              <span className={`mb-2 block text-sm font-semibold ${isLight ? 'text-stone-700' : 'text-white/80'}`}>{t('password')}</span>
              <input
                required
                name="password"
                type="password"
                value={form.password}
                onChange={handleChange}
                placeholder={t('fieldPasswordPlaceholder')}
                className={`w-full rounded-2xl border px-4 py-3 outline-none placeholder:text-stone-400 ${isLight ? 'border-stone-200 bg-stone-50 text-stone-900' : 'border-white/15 bg-slate-950/35 text-white placeholder:text-white/35'}`}
              />
            </label>

            {error ? (
              <div className="rounded-2xl border border-rose-400/35 bg-rose-400/10 px-4 py-3 text-sm text-rose-700">
                {error}
              </div>
            ) : null}

            <button
              type="submit"
              className={`inline-flex w-full items-center justify-center gap-2 rounded-2xl px-4 py-3 text-sm font-black uppercase tracking-[0.16em] shadow-lg ${
                isLight ? 'bg-stone-900 text-stone-50' : 'bg-white text-slate-950'
              }`}
            >
              <LogIn className="h-4 w-4" />
              {mode === 'register' ? t('continue') : t('signIn')}
            </button>
          </form>
        </div>
      </section>
    </main>
  )
}
