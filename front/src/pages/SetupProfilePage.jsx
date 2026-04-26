import { useState } from 'react'
import { ImagePlus, SkipForward, Sparkles } from 'lucide-react'
import AvatarBadge from '../components/AvatarBadge'
import LanguageSwitcher from '../components/LanguageSwitcher'
import ThemeToggle from '../components/ThemeToggle'
import { buildCurrentUserProfile } from '../data/zenlyContent'
import { readFileAsDataUrl } from '../utils/readFileAsDataUrl'

export default function SetupProfilePage({
  currentUser,
  onComplete,
  theme,
  onToggleTheme,
  locale,
  onChangeLocale,
  t,
}) {
  const profile = buildCurrentUserProfile(currentUser)
  const [form, setForm] = useState({
    city: currentUser.city || '',
    place: currentUser.place || currentUser.address || '',
    bio: currentUser.bio || '',
    avatar: currentUser.avatar || '',
  })
  const [isReadingFile, setIsReadingFile] = useState(false)
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
  }

  const handleAvatarChange = async (event) => {
    const file = event.target.files?.[0]
    if (!file) {
      return
    }

    setIsReadingFile(true)
    try {
      const avatar = await readFileAsDataUrl(file)
      setForm((current) => ({ ...current, avatar }))
    } finally {
      setIsReadingFile(false)
      event.target.value = ''
    }
  }

  const handleSubmit = (event) => {
    event.preventDefault()
    onComplete({
      city: form.city.trim(),
      place: form.place.trim(),
      address: form.place.trim(),
      bio: form.bio.trim(),
      avatar: form.avatar,
      setupComplete: true,
    })
  }

  const handleSkip = () => {
    onComplete({
      setupComplete: true,
    })
  }

  return (
    <main className={`relative min-h-screen overflow-hidden ${isLight ? 'bg-[#f7f1e8] text-stone-800' : 'bg-slate-950 text-white'}`}>
      <div className={`absolute inset-0 ${isLight ? 'bg-[radial-gradient(circle_at_15%_10%,rgba(217,119,87,0.06),transparent_32%),radial-gradient(circle_at_82%_12%,rgba(125,211,252,0.06),transparent_28%),linear-gradient(180deg,#faf7f3_0%,#f4efe8_42%,#eee7de_100%)]' : 'bg-[radial-gradient(circle_at_15%_10%,rgba(76,141,255,0.34),transparent_28%),radial-gradient(circle_at_82%_12%,rgba(255,67,164,0.24),transparent_22%),linear-gradient(180deg,#06101f_0%,#101b31_42%,#14254b_100%)]'}`} />
      <div className={`absolute inset-0 ${isLight ? 'bg-[linear-gradient(rgba(120,113,108,0.06)_1px,transparent_1px),linear-gradient(90deg,rgba(120,113,108,0.06)_1px,transparent_1px)]' : 'bg-[linear-gradient(rgba(255,255,255,0.04)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.04)_1px,transparent_1px)]'} bg-[size:52px_52px]`} />

      <section className="relative z-10 mx-auto flex min-h-screen w-full max-w-5xl flex-col justify-center gap-8 px-4 py-8 lg:flex-row lg:items-center lg:gap-12">
        <div className="max-w-xl">
          <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
            <div className={`inline-flex items-center gap-2 rounded-2xl border px-4 py-3 text-sm font-semibold backdrop-blur-xl ${isLight ? 'border-stone-200 bg-[#faf7f3]/96 text-stone-700 shadow-[0_8px_18px_rgba(120,113,108,0.06)]' : 'border-white/15 bg-white/10 text-white/86 shadow-float'}`}>
              <Sparkles className={`h-4 w-4 ${isLight ? 'text-stone-400' : 'text-sky-300'}`} />
              {t('setupBadge')}
            </div>
            <div className="flex items-center gap-3">
              <LanguageSwitcher locale={locale} onChange={onChangeLocale} theme={theme} />
              <ThemeToggle theme={theme} onToggle={onToggleTheme} labels={themeLabels} />
            </div>
          </div>
          <h1 className={`mt-6 text-5xl font-black leading-none tracking-tight sm:text-6xl ${isLight ? 'text-stone-900' : 'text-white'}`}>
            {t('setupTitle')}
          </h1>
          <p className={`mt-4 max-w-lg text-base leading-7 ${isLight ? 'text-stone-600' : 'text-white/72'}`}>
            {t('setupDescription')}
          </p>
        </div>

        <div className={`w-full max-w-md rounded-[2rem] border p-5 backdrop-blur-xl ${isLight ? 'border-stone-200 bg-[#faf7f3]/94 shadow-[0_12px_28px_rgba(120,113,108,0.08)]' : 'border-white/15 bg-white/10 shadow-float'}`}>
          <div className={`flex flex-col items-center gap-4 border p-5 ${isLight ? 'border-stone-200 bg-stone-50/90' : 'border-white/10 bg-slate-950/35'}`}>
            <AvatarBadge avatar={form.avatar} initials={profile.initials} size="lg" alt={t('avatarAlt')} />

            <label className={`inline-flex cursor-pointer items-center gap-2 rounded-2xl border px-4 py-3 text-sm font-semibold ${isLight ? 'border-stone-200 bg-white text-stone-700' : 'border-white/15 bg-white/5 text-white'}`}>
              <ImagePlus className="h-4 w-4" />
              {isReadingFile ? t('uploading') : t('uploadAvatar')}
              <input type="file" accept="image/*" className="hidden" onChange={handleAvatarChange} />
            </label>
          </div>

          <form className="mt-5 grid gap-4" onSubmit={handleSubmit}>
            <label className="block">
              <span className={`mb-2 block text-sm font-semibold ${isLight ? 'text-stone-700' : 'text-white/80'}`}>{t('city')}</span>
              <input name="city" value={form.city} onChange={handleChange} placeholder={t('fieldCityPlaceholder')} className={`w-full rounded-2xl border px-4 py-3 outline-none placeholder:text-stone-400 ${isLight ? 'border-stone-200 bg-stone-50 text-stone-900' : 'border-white/15 bg-slate-950/35 text-white placeholder:text-white/35'}`} />
            </label>

            <label className="block">
              <span className={`mb-2 block text-sm font-semibold ${isLight ? 'text-stone-700' : 'text-white/80'}`}>{t('location')}</span>
              <input name="place" value={form.place} onChange={handleChange} placeholder={t('fieldPlacePlaceholder')} className={`w-full rounded-2xl border px-4 py-3 outline-none placeholder:text-stone-400 ${isLight ? 'border-stone-200 bg-stone-50 text-stone-900' : 'border-white/15 bg-slate-950/35 text-white placeholder:text-white/35'}`} />
            </label>

            <label className="block">
              <span className={`mb-2 block text-sm font-semibold ${isLight ? 'text-stone-700' : 'text-white/80'}`}>{t('about')}</span>
              <textarea name="bio" value={form.bio} onChange={handleChange} rows="4" placeholder={t('fieldBioShortPlaceholder')} className={`w-full rounded-2xl border px-4 py-3 outline-none placeholder:text-stone-400 ${isLight ? 'border-stone-200 bg-stone-50 text-stone-900' : 'border-white/15 bg-slate-950/35 text-white placeholder:text-white/35'}`} />
            </label>

            <button type="submit" className={`inline-flex w-full items-center justify-center gap-2 rounded-2xl px-4 py-3 text-sm font-black uppercase tracking-[0.16em] shadow-lg ${isLight ? 'bg-stone-900 text-stone-50' : 'bg-white text-slate-950'}`}>
              {t('saveAndContinue')}
            </button>

            <button type="button" onClick={handleSkip} className={`inline-flex w-full items-center justify-center gap-2 rounded-2xl border px-4 py-3 text-sm font-bold ${isLight ? 'border-stone-200 bg-white text-stone-700' : 'border-white/15 bg-white/5 text-white'}`}>
              <SkipForward className="h-4 w-4" />
              {t('skipForNow')}
            </button>
          </form>
        </div>
      </section>
    </main>
  )
}
