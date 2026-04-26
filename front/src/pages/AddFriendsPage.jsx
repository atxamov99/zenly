import { useMemo, useState } from 'react'
import { ArrowLeft, Search, Sparkles, Users2 } from 'lucide-react'
import { Link } from 'react-router-dom'
import LanguageSwitcher from '../components/LanguageSwitcher'
import ThemeToggle from '../components/ThemeToggle'
import { peopleList } from '../data/zenlyContent'

export default function AddFriendsPage({ theme, onToggleTheme, locale, onChangeLocale, t }) {
  const isLight = theme === 'light'
  const themeLabels = {
    dark: t('darkTheme'),
    light: t('lightTheme'),
    switchToDark: t('switchToDarkTheme'),
    switchToLight: t('switchToLightTheme'),
  }
  const [query, setQuery] = useState('')
  const [activeFilter, setActiveFilter] = useState('all')
  const statusFilters = [
    { id: 'all', label: t('peopleFilterAll') },
    { id: 'nearby', label: t('nearby') },
    { id: 'recent', label: t('recent') },
    { id: 'open', label: t('peopleFilterOpenProfiles') },
  ]

  const filteredPeople = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase()

    return peopleList.filter((person) => {
      const matchesQuery =
        !normalizedQuery ||
        person.name.toLowerCase().includes(normalizedQuery) ||
        person.username.toLowerCase().includes(normalizedQuery) ||
        person.place.toLowerCase().includes(normalizedQuery)

      if (!matchesQuery) {
        return false
      }

      if (activeFilter === 'all') {
        return true
      }

      if (activeFilter === 'open') {
        return person.availability === 'open'
      }

      return person.status === activeFilter
    })
  }, [activeFilter, query])

  return (
    <main className={`relative min-h-screen overflow-hidden ${isLight ? 'bg-[#f7f1e8] text-stone-800' : 'bg-[#08111f] text-white'}`}>
      <div className={`absolute inset-0 ${isLight ? 'bg-[linear-gradient(180deg,#faf7f3_0%,#f4efe8_48%,#eee7de_100%)]' : 'bg-[linear-gradient(180deg,#060b12_0%,#0b1521_48%,#101c2b_100%)]'}`} />
      <div className={`absolute inset-0 opacity-20 ${isLight ? '[background-image:linear-gradient(rgba(120,113,108,0.12)_1px,transparent_1px),linear-gradient(90deg,rgba(120,113,108,0.12)_1px,transparent_1px)]' : '[background-image:linear-gradient(rgba(255,255,255,0.12)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.12)_1px,transparent_1px)]'} [background-size:42px_42px]`} />

      <section className="relative z-10 mx-auto flex min-h-screen w-full max-w-4xl flex-col px-4 pb-10 pt-5">
        <div className="flex items-center justify-between gap-4">
          <Link
            to="/"
            className={`inline-flex h-12 w-12 items-center justify-center border backdrop-blur-xl ${isLight ? 'border-stone-200 bg-white/80 text-stone-700' : 'border-white/15 bg-white/5 text-white'}`}
            aria-label={t('backToMap')}
          >
            <ArrowLeft className="h-5 w-5" />
          </Link>

          <div className="flex flex-wrap items-center gap-3">
            <div className={`inline-flex items-center gap-2 border px-4 py-2.5 text-sm font-bold backdrop-blur-xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/90 text-stone-700' : 'border-white/15 bg-white/5 text-white/82'}`}>
              <Sparkles className={`h-4 w-4 ${isLight ? 'text-stone-400' : 'text-cyan-300'}`} />
              {t('appName')}
            </div>
            <LanguageSwitcher locale={locale} onChange={onChangeLocale} theme={theme} />
            <ThemeToggle theme={theme} onToggle={onToggleTheme} labels={themeLabels} />
          </div>
        </div>

        <section className={`mt-6 border p-6 backdrop-blur-2xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/88 shadow-[0_10px_22px_rgba(120,113,108,0.07)]' : 'border-white/15 bg-white/[0.04] shadow-float'}`}>
          <p className={`text-xs uppercase tracking-[0.2em] ${isLight ? 'text-stone-500' : 'text-white/55'}`}>{t('people')}</p>
          <h1 className={`mt-3 max-w-lg text-4xl font-black leading-none tracking-tight sm:text-5xl ${isLight ? 'text-stone-900' : 'text-white'}`}>
            {t('people')}
          </h1>
          <p className={`mt-4 max-w-2xl text-sm leading-6 ${isLight ? 'text-stone-600' : 'text-white/72'}`}>
            {t('peopleDescription')}
          </p>

          <div className={`mt-6 flex items-center gap-3 border px-4 py-4 backdrop-blur-xl ${isLight ? 'border-stone-200 bg-stone-50/90' : 'border-white/15 bg-slate-950/55'}`}>
            <Search className={`h-5 w-5 ${isLight ? 'text-stone-400' : 'text-white/52'}`} />
            <input
              type="text"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder={t('searchPeople')}
              className={`w-full bg-transparent text-sm outline-none ${isLight ? 'text-stone-700 placeholder:text-stone-400' : 'text-white placeholder:text-white/42'}`}
            />
          </div>

          <div className="mt-4 flex flex-wrap gap-2">
            {statusFilters.map((filter) => (
              <button
                key={filter.id}
                type="button"
                onClick={() => setActiveFilter(filter.id)}
                className={`border px-4 py-2 text-xs font-bold uppercase tracking-[0.14em] ${
                  activeFilter === filter.id
                    ? isLight
                      ? 'border-stone-900 bg-stone-900 text-stone-50'
                      : 'border-white bg-white text-slate-950'
                    : isLight
                      ? 'border-stone-200 bg-white/85 text-stone-600'
                      : 'border-white/15 bg-white/5 text-white/74'
                }`}
              >
                {filter.label}
              </button>
            ))}
          </div>
        </section>

        <section className={`mt-6 border p-6 backdrop-blur-2xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/88 shadow-[0_10px_22px_rgba(120,113,108,0.07)]' : 'border-white/15 bg-white/[0.04] shadow-float'}`}>
          <div className="flex items-center justify-between gap-4">
            <div>
              <p className={`text-xs uppercase tracking-[0.2em] ${isLight ? 'text-stone-500' : 'text-white/55'}`}>
                {t('peopleDiscovery')}
              </p>
              <h2 className={`mt-2 text-2xl font-black tracking-tight ${isLight ? 'text-stone-900' : 'text-white'}`}>
                {t('peopleListTitle')}
              </h2>
            </div>
            <div className={`inline-flex items-center gap-2 border px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] ${isLight ? 'border-stone-200 bg-white text-stone-600' : 'border-white/15 bg-white/5 text-white/74'}`}>
              <Users2 className="h-4 w-4" />
              {t('peopleShownCount', { count: filteredPeople.length })}
            </div>
          </div>

          {filteredPeople.length === 0 ? (
            <div className={`mt-6 border border-dashed p-8 ${isLight ? 'border-stone-300 bg-[#fffaf4]' : 'border-white/18 bg-slate-950/40'}`}>
              <p className={`text-sm font-bold uppercase tracking-[0.16em] ${isLight ? 'text-stone-800' : 'text-white'}`}>
                {peopleList.length === 0 ? t('emptyYet') : t('peopleNoMatches')}
              </p>
              <p className={`mt-3 max-w-xl text-sm leading-6 ${isLight ? 'text-stone-600' : 'text-white/64'}`}>
                {peopleList.length === 0
                  ? t('emptyPeopleText')
                  : t('peopleNoMatchesText')}
              </p>
            </div>
          ) : (
            <div className={`mt-6 grid gap-px border ${isLight ? 'border-stone-200 bg-stone-200' : 'border-white/10 bg-white/10'}`}>
              <div className="grid gap-px md:grid-cols-[1.2fr_1fr_1fr]">
                {[t('tableName'), t('tablePlace'), t('tableLastVisit')].map((label) => (
                  <div
                    key={label}
                    className={`${isLight ? 'bg-[#f8f3ec] text-stone-500' : 'bg-[#09111a] text-white/45'} px-4 py-5 text-xs font-bold uppercase tracking-[0.18em]`}
                  >
                    {label}
                  </div>
                ))}
              </div>

              {filteredPeople.map((person) => (
                <div key={person.id} className="grid gap-px md:grid-cols-[1.2fr_1fr_1fr]">
                  <div className={`${isLight ? 'bg-[#fffaf4] text-stone-900' : 'bg-[#060b12] text-white'} px-4 py-5`}>
                    <p className="text-sm font-bold">{person.name}</p>
                    <p className={`mt-1 text-sm ${isLight ? 'text-stone-500' : 'text-white/58'}`}>@{person.username}</p>
                  </div>
                  <div className={`${isLight ? 'bg-[#fffaf4] text-stone-700' : 'bg-[#060b12] text-white/76'} px-4 py-5 text-sm`}>
                    {person.place}
                  </div>
                  <div className={`${isLight ? 'bg-[#fffaf4] text-stone-700' : 'bg-[#060b12] text-white/76'} px-4 py-5 text-sm`}>
                    {person.lastVisit}
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>
      </section>
    </main>
  )
}
