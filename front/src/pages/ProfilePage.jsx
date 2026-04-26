import { useEffect, useRef, useState } from 'react'
import {
  ArrowLeft,
  Calendar,
  ImagePlus,
  LogOut,
  Mail,
  MapPin,
  Pencil,
  Save,
  Settings,
  Sparkles,
  Trash2,
  User,
} from 'lucide-react'
import { Link } from 'react-router-dom'
import AvatarBadge from '../components/AvatarBadge'
import LanguageSwitcher from '../components/LanguageSwitcher'
import ThemeToggle from '../components/ThemeToggle'
import { buildCurrentUserProfile } from '../data/zenlyContent'
import { getLocaleDateTag } from '../i18n/translations'
import { readFileAsDataUrl } from '../utils/readFileAsDataUrl'

function InfoCard({ icon: Icon, label, value, hint, isLight }) {
  return (
    <article className={`border p-4 backdrop-blur-2xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/88 shadow-[0_10px_22px_rgba(120,113,108,0.07)]' : 'border-white/15 bg-white/[0.04] shadow-float'}`}>
      <div className={`flex items-center gap-2 text-sm font-semibold ${isLight ? 'text-stone-800' : 'text-white/84'}`}>
        <Icon className={`h-4 w-4 ${isLight ? 'text-stone-400' : 'text-cyan-300'}`} />
        {label}
      </div>
      <p className={`mt-3 text-lg font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>{value}</p>
      <p className={`mt-2 text-sm ${isLight ? 'text-stone-600' : 'text-white/68'}`}>{hint}</p>
    </article>
  )
}

function formatCreatedAt(value, locale, t) {
  if (!value) return t('unavailable')
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return t('unavailable')
  return new Intl.DateTimeFormat(getLocaleDateTag(locale), {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  }).format(date)
}

export default function ProfilePage({
  currentUser,
  onLogout,
  onUpdateCurrentUser,
  theme,
  onToggleTheme,
  locale,
  onChangeLocale,
  t,
}) {
  const profile = buildCurrentUserProfile(currentUser)
  const fileInputRef = useRef(null)
  const [isEditing, setIsEditing] = useState(false)
  const [saveState, setSaveState] = useState('idle')
  const [isReadingFile, setIsReadingFile] = useState(false)
  const [form, setForm] = useState({
    name: currentUser.name || '',
    username: currentUser.username || '',
    city: currentUser.city || '',
    place: currentUser.place || currentUser.address || '',
    bio: currentUser.bio || '',
    avatar: currentUser.avatar || '',
  })
  const isLight = theme === 'light'
  const themeLabels = {
    dark: t('darkTheme'),
    light: t('lightTheme'),
    switchToDark: t('switchToDarkTheme'),
    switchToLight: t('switchToLightTheme'),
  }

  useEffect(() => {
    setForm({
      name: currentUser.name || '',
      username: currentUser.username || '',
      city: currentUser.city || '',
      place: currentUser.place || currentUser.address || '',
      bio: currentUser.bio || '',
      avatar: currentUser.avatar || '',
    })
    setSaveState('idle')
  }, [currentUser])

  const handleChange = (event) => {
    const { name, value } = event.target
    setForm((current) => ({ ...current, [name]: value }))
    setSaveState('idle')
  }

  const handleAvatarChange = async (event) => {
    const file = event.target.files?.[0]
    if (!file) {
      return
    }

    setIsReadingFile(true)
    setSaveState('idle')

    try {
      const avatar = await readFileAsDataUrl(file)
      setForm((current) => ({ ...current, avatar }))
    } finally {
      setIsReadingFile(false)
      event.target.value = ''
    }
  }

  const handleRemoveAvatar = () => {
    setForm((current) => ({ ...current, avatar: '' }))
    setSaveState('idle')
  }

  const handleSubmit = (event) => {
    event.preventDefault()
    onUpdateCurrentUser({
      name: form.name.trim() || currentUser.name,
      username: form.username.trim() || currentUser.username,
      city: form.city.trim(),
      place: form.place.trim(),
      address: form.place.trim(),
      bio: form.bio.trim(),
      avatar: form.avatar,
    })
    setSaveState('saved')
    setIsEditing(false)
  }

  return (
    <main className={`relative min-h-screen overflow-hidden ${isLight ? 'bg-[#f7f1e8] text-stone-800' : 'bg-[#08111f] text-white'}`}>
      <div className={`absolute inset-0 ${isLight ? 'bg-[linear-gradient(180deg,#faf7f3_0%,#f4efe8_48%,#eee7de_100%)]' : 'bg-[linear-gradient(180deg,#060b12_0%,#0b1521_48%,#101c2b_100%)]'}`} />
      <div className={`absolute inset-0 opacity-20 ${isLight ? '[background-image:linear-gradient(rgba(120,113,108,0.12)_1px,transparent_1px),linear-gradient(90deg,rgba(120,113,108,0.12)_1px,transparent_1px)]' : '[background-image:linear-gradient(rgba(255,255,255,0.12)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.12)_1px,transparent_1px)]'} [background-size:42px_42px]`} />

      <section className="relative z-10 mx-auto flex min-h-screen w-full max-w-5xl flex-col px-4 pb-10 pt-5">
        <div className="flex items-center justify-between gap-3">
          <Link to="/" className={`inline-flex h-12 w-12 items-center justify-center border backdrop-blur-xl ${isLight ? 'border-stone-200 bg-white/80 text-stone-700' : 'border-white/20 bg-white/5 text-white shadow-float'}`} aria-label={t('backToMap')}>
            <ArrowLeft className="h-5 w-5" />
          </Link>

          <div className="flex flex-wrap items-center justify-end gap-3">
            <div className={`inline-flex items-center gap-2 border px-4 py-2.5 text-sm font-semibold backdrop-blur-xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/90 text-stone-700' : 'border-white/15 bg-white/5 text-white shadow-float'}`}>
              <Sparkles className={`h-4 w-4 ${isLight ? 'text-stone-400' : 'text-cyan-300'}`} />
              {t('appName')}
            </div>
            <LanguageSwitcher locale={locale} onChange={onChangeLocale} theme={theme} />
            <ThemeToggle theme={theme} onToggle={onToggleTheme} labels={themeLabels} />
            <Link
              to="/settings"
              className={`inline-flex h-12 w-12 items-center justify-center border backdrop-blur-xl ${isLight ? 'border-stone-200 bg-white/80 text-stone-700' : 'border-white/20 bg-white/5 text-white shadow-float'}`}
              aria-label={t('openSettings')}
            >
              <Settings className="h-5 w-5" />
            </Link>
            <button type="button" onClick={onLogout} className={`inline-flex h-12 w-12 items-center justify-center border backdrop-blur-xl ${isLight ? 'border-stone-200 bg-white/80 text-stone-700' : 'border-white/20 bg-white/5 text-white shadow-float'}`} aria-label={t('logout')}>
              <LogOut className="h-5 w-5" />
            </button>
          </div>
        </div>

        <div className="mt-6 grid gap-6 lg:grid-cols-[1.2fr_0.8fr]">
          <section className={`border p-6 backdrop-blur-2xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/88 shadow-[0_10px_22px_rgba(120,113,108,0.07)]' : 'border-white/15 bg-white/[0.04] shadow-float'}`}>
            <div className="flex flex-col gap-5 sm:flex-row sm:items-center">
              <AvatarBadge avatar={profile.avatar} initials={profile.initials} size="lg" alt={t('avatarAlt')} />
              <div className="min-w-0 flex-1">
                <p className={`text-xs uppercase tracking-[0.2em] ${isLight ? 'text-stone-500' : 'text-white/55'}`}>{t('profile')}</p>
                <h1 className={`mt-2 text-4xl font-black tracking-tight ${isLight ? 'text-stone-900' : 'text-white'}`}>{profile.name}</h1>
                <p className={`mt-1 text-sm ${isLight ? 'text-stone-500' : 'text-white/65'}`}>{profile.handle}</p>
                <p className={`mt-4 max-w-2xl text-sm leading-6 ${isLight ? 'text-stone-600' : 'text-white/74'}`}>
                  {profile.bio || t('profileBioFallback')}
                </p>
              </div>
            </div>

            <div className={`mt-6 border p-4 ${isLight ? 'border-stone-200 bg-stone-50/90' : 'border-white/10 bg-slate-950/24'}`}>
              <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                <div className="flex items-center gap-3">
                  <AvatarBadge avatar={profile.avatar} initials={profile.initials} size="md" alt={t('avatarAlt')} />
                  <div>
                    <p className={`text-sm font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>{t('avatar')}</p>
                    <p className={`text-sm ${isLight ? 'text-stone-600' : 'text-white/64'}`}>{t('avatarDescription')}</p>
                  </div>
                </div>
                <div className="flex flex-wrap gap-2">
                  <button
                    type="button"
                    onClick={() => {
                      setIsEditing(true)
                      fileInputRef.current?.click()
                    }}
                    className={`inline-flex items-center gap-2 rounded-2xl border px-4 py-3 text-sm font-bold ${isLight ? 'border-stone-200 bg-white text-stone-700' : 'border-white/15 bg-white/5 text-white'}`}
                  >
                    <ImagePlus className="h-4 w-4" />
                    {t('change')}
                  </button>
                  {profile.avatar ? (
                    <button
                      type="button"
                      onClick={() => {
                        setIsEditing(true)
                        handleRemoveAvatar()
                      }}
                      className={`inline-flex items-center gap-2 rounded-2xl border px-4 py-3 text-sm font-bold ${isLight ? 'border-stone-200 bg-white text-stone-700' : 'border-white/15 bg-white/5 text-white'}`}
                    >
                      <Trash2 className="h-4 w-4" />
                      {t('remove')}
                    </button>
                  ) : null}
                </div>
              </div>
            </div>

            <div className="mt-6 grid gap-4 sm:grid-cols-2">
              <div className={`border p-4 ${isLight ? 'border-stone-200 bg-stone-50/90' : 'border-white/10 bg-slate-950/24'}`}>
                <div className={`flex items-center gap-2 text-sm font-semibold ${isLight ? 'text-stone-800' : 'text-white'}`}>
                  <MapPin className={`h-4 w-4 ${isLight ? 'text-stone-400' : 'text-cyan-300'}`} />
                  {t('location')}
                </div>
                <p className={`mt-2 text-lg font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>{profile.place || t('locationNotSpecified')}</p>
                <p className={`mt-1 text-sm ${isLight ? 'text-stone-600' : 'text-white/65'}`}>{profile.city || t('cityNotSpecified')}</p>
              </div>

              <div className={`border p-4 ${isLight ? 'border-stone-200 bg-stone-50/90' : 'border-white/10 bg-slate-950/24'}`}>
                <div className={`flex items-center gap-2 text-sm font-semibold ${isLight ? 'text-stone-800' : 'text-white'}`}>
                  <Mail className={`h-4 w-4 ${isLight ? 'text-stone-400' : 'text-cyan-300'}`} />
                  {t('email')}
                </div>
                <p className={`mt-2 break-all text-lg font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>{profile.email || t('unavailable')}</p>
                <p className={`mt-1 text-sm ${isLight ? 'text-stone-600' : 'text-white/65'}`}>{t('emailDescription')}</p>
              </div>
            </div>
          </section>

          <section className="grid gap-4">
            <InfoCard icon={User} label={t('username')} value={profile.handle} hint={t('usernameHint')} isLight={isLight} />
            <InfoCard icon={Calendar} label={t('createdAt')} value={formatCreatedAt(profile.createdAt, locale, t)} hint={t('createdAtHint')} isLight={isLight} />
            <InfoCard icon={MapPin} label={t('dataSource')} value={t('localProfile')} hint={t('localProfileHint')} isLight={isLight} />
          </section>
        </div>

        <section className={`mt-6 border p-6 backdrop-blur-2xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/88 shadow-[0_10px_22px_rgba(120,113,108,0.07)]' : 'border-white/15 bg-white/[0.04] shadow-float'}`}>
          <div className="flex items-center justify-between gap-3">
            <div>
              <p className={`text-xs uppercase tracking-[0.2em] ${isLight ? 'text-stone-500' : 'text-white/55'}`}>{t('profile')}</p>
              <h2 className={`mt-2 text-2xl font-black tracking-tight ${isLight ? 'text-stone-900' : 'text-white'}`}>{t('yourData')}</h2>
            </div>
            <button type="button" onClick={() => { setIsEditing((current) => !current); setSaveState('idle') }} className={`inline-flex items-center gap-2 rounded-2xl border px-4 py-3 text-sm font-bold ${isLight ? 'border-stone-200 bg-white text-stone-700' : 'border-white/15 bg-white/5 text-white'}`}>
              <Pencil className="h-4 w-4" />
              {isEditing ? t('hideForm') : t('editProfile')}
            </button>
          </div>

          <div className="mt-5 grid gap-4 md:grid-cols-2">
            <div className={`border p-4 ${isLight ? 'border-stone-200 bg-stone-50/90' : 'border-white/10 bg-slate-950/24'}`}>
              <p className={`text-sm font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>{t('about')}</p>
              <p className={`mt-2 text-sm leading-6 ${isLight ? 'text-stone-600' : 'text-white/68'}`}>{profile.bio || t('aboutEmpty')}</p>
            </div>
            <div className={`border p-4 ${isLight ? 'border-stone-200 bg-stone-50/90' : 'border-white/10 bg-slate-950/24'}`}>
              <p className={`text-sm font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>{t('manage')}</p>
              <p className={`mt-2 text-sm leading-6 ${isLight ? 'text-stone-600' : 'text-white/68'}`}>{t('manageText')}</p>
            </div>
          </div>
        </section>

        {isEditing ? (
          <section className={`mt-6 border p-6 backdrop-blur-2xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/88 shadow-[0_10px_22px_rgba(120,113,108,0.07)]' : 'border-white/15 bg-white/[0.04] shadow-float'}`}>
            <div className="flex items-center justify-between gap-3">
              <div>
                <p className={`text-xs uppercase tracking-[0.2em] ${isLight ? 'text-stone-500' : 'text-white/55'}`}>{t('editing')}</p>
                <h2 className={`mt-2 text-2xl font-black tracking-tight ${isLight ? 'text-stone-900' : 'text-white'}`}>{t('editProfile')}</h2>
              </div>
              <div className={isLight ? 'text-xs uppercase tracking-[0.14em] text-stone-400' : 'text-xs uppercase tracking-[0.14em] text-white/45'}>{t('localStorage')}</div>
            </div>

            <form className="mt-5 grid gap-4 md:grid-cols-2" onSubmit={handleSubmit}>
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                className="hidden"
                onChange={handleAvatarChange}
              />

              <div className="md:col-span-2">
                <div className={`rounded-[1.6rem] border p-4 ${isLight ? 'border-stone-200 bg-stone-50/90' : 'border-white/10 bg-slate-950/24'}`}>
                  <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                    <div className="flex items-center gap-3">
                      <AvatarBadge avatar={form.avatar} initials={profile.initials} size="md" alt={t('avatarAlt')} />
                      <div>
                        <p className={`text-sm font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>{t('avatarProfile')}</p>
                        <p className={`text-sm ${isLight ? 'text-stone-600' : 'text-white/64'}`}>
                          {isReadingFile ? t('avatarFileLoading') : t('avatarEditHint')}
                        </p>
                      </div>
                    </div>

                    <div className="flex flex-wrap gap-2">
                      <button
                        type="button"
                        onClick={() => fileInputRef.current?.click()}
                        className={`inline-flex items-center gap-2 rounded-2xl border px-4 py-3 text-sm font-bold ${isLight ? 'border-stone-200 bg-white text-stone-700' : 'border-white/15 bg-white/5 text-white'}`}
                      >
                        <ImagePlus className="h-4 w-4" />
                        {t('choosePhoto')}
                      </button>
                      {form.avatar ? (
                        <button
                          type="button"
                          onClick={handleRemoveAvatar}
                          className={`inline-flex items-center gap-2 rounded-2xl border px-4 py-3 text-sm font-bold ${isLight ? 'border-stone-200 bg-white text-stone-700' : 'border-white/15 bg-white/5 text-white'}`}
                        >
                          <Trash2 className="h-4 w-4" />
                          {t('remove')}
                        </button>
                      ) : null}
                    </div>
                  </div>
                </div>
              </div>

              {[
                ['name', t('name'), t('fieldNamePlaceholder')],
                ['username', t('username'), t('fieldUsernamePlaceholder')],
                ['city', t('city'), t('fieldCityPlaceholder')],
                ['place', t('location'), t('fieldPlacePlaceholder')],
              ].map(([name, label, placeholder]) => (
                <label key={name} className="block">
                  <span className={`mb-2 block text-sm font-semibold ${isLight ? 'text-stone-700' : 'text-white/80'}`}>{label}</span>
                  <input
                    name={name}
                    value={form[name]}
                    onChange={handleChange}
                    placeholder={placeholder}
                    className={`w-full rounded-2xl border px-4 py-3 outline-none placeholder:text-stone-400 ${isLight ? 'border-stone-200 bg-stone-50 text-stone-900' : 'border-white/15 bg-slate-950/35 text-white placeholder:text-white/35'}`}
                  />
                </label>
              ))}

              <label className="block md:col-span-2">
                <span className={`mb-2 block text-sm font-semibold ${isLight ? 'text-stone-700' : 'text-white/80'}`}>{t('about')}</span>
                <textarea
                  name="bio"
                  value={form.bio}
                  onChange={handleChange}
                  rows="4"
                  placeholder={t('fieldBioPlaceholder')}
                  className={`w-full rounded-2xl border px-4 py-3 outline-none placeholder:text-stone-400 ${isLight ? 'border-stone-200 bg-stone-50 text-stone-900' : 'border-white/15 bg-slate-950/35 text-white placeholder:text-white/35'}`}
                />
              </label>

              <div className={`text-sm md:col-span-2 ${isLight ? 'text-stone-500' : 'text-white/64'}`}>
                {saveState === 'saved' ? t('profileSaved') : t('profileEditHint')}
              </div>

              <button type="submit" className={`inline-flex items-center justify-center rounded-2xl px-4 py-3 text-sm font-black uppercase tracking-[0.16em] shadow-lg md:col-span-2 ${isLight ? 'bg-stone-900 text-stone-50' : 'bg-white text-slate-950'}`}>
                <Save className="mr-2 h-4 w-4" />
                {t('saveProfile')}
              </button>
            </form>
          </section>
        ) : null}
      </section>
    </main>
  )
}
