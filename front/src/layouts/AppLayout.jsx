import { useEffect, useRef } from 'react'
import { Compass, LogOut, MapPin, Zap } from 'lucide-react'
import { Link, NavLink } from 'react-router-dom'
import AvatarBadge from '../components/AvatarBadge'
import LanguageSwitcher from '../components/LanguageSwitcher'
import LiveMap from '../components/LiveMap'
import ThemeToggle from '../components/ThemeToggle'
import { buildCurrentUserProfile, getFeedCards, places } from '../data/zenlyContent'
import { getSocket } from '../services/socket'

function Logo({ isLight, title }) {
  return (
    <div className={`inline-flex items-center gap-3 border px-4 py-3 backdrop-blur-xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/90 shadow-[0_8px_18px_rgba(120,113,108,0.06)]' : 'border-white/20 bg-white/5'}`}>
      <span className={`flex h-10 w-10 items-center justify-center border text-sm font-black tracking-[0.2em] ${isLight ? 'border-stone-300 bg-stone-100 text-stone-600' : 'border-cyan-300/60 bg-cyan-300/10 text-cyan-100'}`}>
        Z
      </span>
      <span className={isLight ? 'text-lg font-black tracking-tight text-stone-900' : 'text-lg font-black tracking-tight text-white'}>{title}</span>
    </div>
  )
}

function BottomNav({ isLight, items }) {
  return (
    <nav className="fixed bottom-4 left-1/2 z-30 w-[calc(100%-1.5rem)] max-w-sm -translate-x-1/2">
      <div className={`grid grid-cols-3 border p-2 backdrop-blur-2xl ${isLight ? 'border-stone-200 bg-[#faf7f3]/94 shadow-[0_10px_22px_rgba(120,113,108,0.08)]' : 'border-white/20 bg-slate-950/86 shadow-float'}`}>
        {items.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.to === '/'}
            className={({ isActive }) =>
              `px-4 py-3 text-center text-sm font-bold uppercase tracking-[0.12em] transition ${
                isActive
                  ? isLight
                    ? 'bg-stone-900 text-stone-50'
                    : 'bg-cyan-300/12 text-cyan-100'
                  : isLight
                    ? 'text-stone-500'
                    : 'text-white/58'
              }`
            }
          >
            {item.label}
          </NavLink>
        ))}
      </div>
    </nav>
  )
}

export default function AppLayout({
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
  const isLight = theme === 'light'
  const locationThrottle = useRef(null)

  useEffect(() => {
    return () => clearTimeout(locationThrottle.current)
  }, [])
  const themeLabels = {
    dark: t('darkTheme'),
    light: t('lightTheme'),
    switchToDark: t('switchToDarkTheme'),
    switchToLight: t('switchToLightTheme'),
  }
  const feedCards = getFeedCards(t, profile.city)
  const bottomNavItems = [
    { to: '/', label: t('map') },
    { to: '/people', label: t('people') },
    { to: '/profile', label: t('profile') },
  ]

  const handleLocationChange = (coordinates) => {
    onUpdateCurrentUser({
      coordinates,
      place: t('currentGeoposition'),
      address: t('currentGeoposition'),
      city: currentUser.city || '',
    })
    clearTimeout(locationThrottle.current)
    locationThrottle.current = setTimeout(() => {
      const socket = getSocket()
      if (socket?.connected) {
        socket.emit('location:update', {
          latitude: coordinates[1],
          longitude: coordinates[0],
        })
      }
    }, 5000)
  }

  return (
    <main className={`relative min-h-screen overflow-hidden ${isLight ? 'bg-[#f7f1e8] text-stone-800' : 'bg-[#08111f] text-white'}`}>
      <div className={`absolute inset-0 ${isLight ? 'bg-[linear-gradient(180deg,#faf7f3_0%,#f4efe8_48%,#eee7de_100%)]' : 'bg-[linear-gradient(180deg,#060b12_0%,#0b1521_48%,#101c2b_100%)]'}`} />
      <div className={`absolute inset-0 opacity-20 ${isLight ? '[background-image:linear-gradient(rgba(120,113,108,0.12)_1px,transparent_1px),linear-gradient(90deg,rgba(120,113,108,0.12)_1px,transparent_1px)]' : '[background-image:linear-gradient(rgba(255,255,255,0.12)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.12)_1px,transparent_1px)]'} [background-size:42px_42px]`} />
      <div className={`absolute inset-[4%] border ${isLight ? 'border-stone-200/60 bg-[linear-gradient(180deg,rgba(255,255,255,0.52),rgba(255,255,255,0.12))]' : 'border-white/10 bg-[linear-gradient(180deg,rgba(255,255,255,0.04),rgba(255,255,255,0.01))]'}`} />

      <section className="relative z-10 mx-auto flex min-h-screen w-full max-w-7xl flex-col px-4 pb-28 pt-5">
        <div className="flex items-start justify-between gap-4">
          <Logo isLight={isLight} title={t('appName')} />
          <div className="flex flex-col items-end gap-3">
            <div className="flex flex-wrap items-center justify-end gap-3">
              <div className={`border px-4 py-2 text-xs font-bold uppercase tracking-[0.18em] backdrop-blur-xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/90 text-stone-600' : 'border-white/20 bg-white/5 text-white/78'}`}>
                {t('cityView')}
              </div>
              <LanguageSwitcher locale={locale} onChange={onChangeLocale} theme={theme} />
              <ThemeToggle theme={theme} onToggle={onToggleTheme} labels={themeLabels} />
            </div>
            <div className="flex items-center gap-3">
              <Link to="/profile" className={`inline-flex items-center gap-3 border px-3 py-2.5 backdrop-blur-xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/90' : 'border-white/20 bg-white/5'}`}>
                <AvatarBadge avatar={profile.avatar} initials={profile.initials} size="sm" alt={t('avatarAlt')} />
                <span className="hidden text-left sm:block">
                  <span className={`block text-xs uppercase tracking-[0.18em] ${isLight ? 'text-stone-500' : 'text-white/55'}`}>{t('you')}</span>
                  <span className={`block text-sm font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>{profile.name}</span>
                </span>
              </Link>
              <button type="button" onClick={onLogout} className={`inline-flex h-12 w-12 items-center justify-center border backdrop-blur-xl ${isLight ? 'border-stone-200 bg-white/80 text-stone-700' : 'border-white/20 bg-white/5 text-white'}`} aria-label={t('logout')}>
                <LogOut className="h-5 w-5" />
              </button>
            </div>
          </div>
        </div>

        <div className="mt-6 grid flex-1 gap-6 xl:grid-cols-[1.2fr_0.8fr]">
          <section className={`relative min-h-[34rem] overflow-hidden border backdrop-blur-2xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/78 shadow-[0_12px_24px_rgba(120,113,108,0.07)]' : 'border-white/15 bg-white/[0.03] shadow-float'}`}>
            <div className="absolute left-5 top-5 z-10 flex flex-wrap gap-3">
              <div className={`border px-4 py-2 text-sm font-semibold uppercase tracking-[0.12em] backdrop-blur-xl ${isLight ? 'border-stone-200 bg-white/92 text-stone-700' : 'border-white/15 bg-slate-950/75 text-white'}`}>
                {profile.city || t('cityNotSpecified')}
              </div>
              <div className={`border px-4 py-2 text-sm font-semibold uppercase tracking-[0.12em] backdrop-blur-xl ${isLight ? 'border-stone-200 bg-white/92 text-stone-700' : 'border-white/15 bg-slate-950/75 text-white'}`}>
                {t('yourMap')}
              </div>
            </div>

            <div className={`absolute bottom-5 left-5 z-10 max-w-xs border p-4 backdrop-blur-xl ${isLight ? 'border-stone-200 bg-white/92' : 'border-white/15 bg-slate-950/82'}`}>
              <p className={`text-xs uppercase tracking-[0.18em] ${isLight ? 'text-stone-500' : 'text-white/55'}`}>{t('currentPoint')}</p>
              <h1 className={`mt-2 text-3xl font-black tracking-tight ${isLight ? 'text-stone-900' : 'text-white'}`}>{profile.place || t('locationNotSpecified')}</h1>
              <p className={`mt-2 text-sm leading-6 ${isLight ? 'text-stone-600' : 'text-white/72'}`}>{profile.bio || t('profileBioFallback')}</p>
            </div>

            <LiveMap currentUser={profile} places={places} onLocationChange={handleLocationChange} avatarAlt={t('avatarAlt')} />
          </section>

          <aside className="flex flex-col gap-4">
            <section className={`border p-5 backdrop-blur-2xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/88 shadow-[0_10px_22px_rgba(120,113,108,0.07)]' : 'border-white/15 bg-white/[0.04] shadow-float'}`}>
              <div className="flex items-center justify-between gap-4">
                <div>
                  <p className={`text-xs uppercase tracking-[0.18em] ${isLight ? 'text-stone-500' : 'text-white/55'}`}>{t('status')}</p>
                  <h2 className={`mt-2 text-3xl font-black tracking-tight ${isLight ? 'text-stone-900' : 'text-white'}`}>{t('you')}</h2>
                </div>
                <div className={`border px-3 py-1 text-xs font-bold uppercase tracking-[0.16em] ${isLight ? 'border-emerald-200 bg-emerald-50 text-emerald-700' : 'border-cyan-300/30 bg-cyan-300/10 text-cyan-100'}`}>
                  {t('online')}
                </div>
              </div>

              <article className={`mt-5 border px-4 py-4 ${isLight ? 'border-stone-200 bg-stone-50/90' : 'border-white/12 bg-slate-950/55'}`}>
                <div className="flex items-center gap-3">
                  <AvatarBadge avatar={profile.avatar} initials={profile.initials} size="md" alt={t('avatarAlt')} />
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center justify-between gap-3">
                      <p className={`truncate text-sm font-bold uppercase tracking-[0.12em] ${isLight ? 'text-stone-900' : 'text-white'}`}>{profile.name}</p>
                      <p className={`text-xs uppercase tracking-[0.12em] ${isLight ? 'text-stone-400' : 'text-white/52'}`}>{t('now')}</p>
                    </div>
                    <p className={`mt-1 text-sm ${isLight ? 'text-stone-600' : 'text-white/66'}`}>{profile.place || t('locationNotSpecified')}</p>
                  </div>
                </div>
              </article>
            </section>

            <section className="grid gap-4 sm:grid-cols-3 xl:grid-cols-1">
              {feedCards.map((card) => (
                <article key={card.title} className={`border p-5 backdrop-blur-2xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/88 shadow-[0_10px_22px_rgba(120,113,108,0.07)]' : 'border-white/15 bg-white/[0.04] shadow-float'}`}>
                  <p className={`text-xs uppercase tracking-[0.18em] ${isLight ? 'text-stone-500' : 'text-white/55'}`}>{card.title}</p>
                  <p className={`mt-2 text-2xl font-black tracking-tight ${isLight ? 'text-stone-900' : 'text-white'}`}>{card.value}</p>
                  <p className={`mt-2 text-sm leading-6 ${isLight ? 'text-stone-600' : 'text-white/70'}`}>{card.text}</p>
                </article>
              ))}
            </section>
          </aside>
        </div>

        <section className="relative z-10 mt-6 grid gap-4 lg:grid-cols-3">
          {[
            [t('overview'), t('overviewText'), Compass],
            [t('mapPoints'), t('mapPointsText'), MapPin],
            [t('profile'), t('profileCardText'), Zap],
          ].map(([title, text, Icon]) => (
            <article key={title} className={`border p-5 backdrop-blur-2xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/88 shadow-[0_10px_22px_rgba(120,113,108,0.07)]' : 'border-white/15 bg-white/[0.04] shadow-float'}`}>
              <div className={`flex items-center gap-2 text-sm font-semibold ${isLight ? 'text-stone-800' : 'text-white'}`}>
                <Icon className={`h-4 w-4 ${isLight ? 'text-stone-400' : 'text-cyan-300'}`} />
                {title}
              </div>
              <p className={`mt-3 text-sm leading-6 ${isLight ? 'text-stone-600' : 'text-white/70'}`}>{text}</p>
            </article>
          ))}
        </section>
      </section>

      <BottomNav isLight={isLight} items={bottomNavItems} />
    </main>
  )
}
