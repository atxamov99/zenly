import { useEffect, useRef, useState } from 'react'
import { ArrowLeft, Check, Search, Sparkles, UserPlus, Users2 } from 'lucide-react'
import { Link } from 'react-router-dom'
import LanguageSwitcher from '../components/LanguageSwitcher'
import ThemeToggle from '../components/ThemeToggle'
import { api } from '../services/api'

export default function AddFriendsPage({ theme, onToggleTheme, locale, onChangeLocale, t }) {
  const isLight = theme === 'light'
  const themeLabels = {
    dark: t('darkTheme'),
    light: t('lightTheme'),
    switchToDark: t('switchToDarkTheme'),
    switchToLight: t('switchToLightTheme'),
  }

  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [friends, setFriends] = useState([])
  const [searching, setSearching] = useState(false)
  const [sent, setSent] = useState({})
  const debounceRef = useRef(null)

  useEffect(() => {
    api.getFriends()
      .then((data) => setFriends(data.friends || []))
      .catch(() => {})
  }, [])

  const handleSearch = (value) => {
    setQuery(value)
    clearTimeout(debounceRef.current)
    if (!value.trim()) {
      setResults([])
      return
    }
    debounceRef.current = setTimeout(async () => {
      setSearching(true)
      try {
        const data = await api.searchUsers(value.trim())
        setResults(data.users || data || [])
      } catch {
        setResults([])
      } finally {
        setSearching(false)
      }
    }, 350)
  }

  const handleAdd = async (username) => {
    try {
      await api.sendFriendRequest(username)
      setSent((prev) => ({ ...prev, [username]: true }))
    } catch {}
  }

  const list = query.trim() ? results : friends

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
          <h1 className={`mt-3 text-4xl font-black leading-none tracking-tight sm:text-5xl ${isLight ? 'text-stone-900' : 'text-white'}`}>
            {t('people')}
          </h1>

          <div className={`mt-6 flex items-center gap-3 border px-4 py-4 backdrop-blur-xl ${isLight ? 'border-stone-200 bg-stone-50/90' : 'border-white/15 bg-slate-950/55'}`}>
            <Search className={`h-5 w-5 flex-shrink-0 ${isLight ? 'text-stone-400' : 'text-white/52'}`} />
            <input
              type="text"
              value={query}
              onChange={(e) => handleSearch(e.target.value)}
              placeholder={t('searchPeople')}
              className={`w-full bg-transparent text-sm outline-none ${isLight ? 'text-stone-700 placeholder:text-stone-400' : 'text-white placeholder:text-white/42'}`}
            />
            {searching && <div className="h-4 w-4 animate-spin rounded-full border-2 border-white/20 border-t-white" />}
          </div>
        </section>

        <section className={`mt-6 border p-6 backdrop-blur-2xl ${isLight ? 'border-stone-200 bg-[#fbf8f4]/88 shadow-[0_10px_22px_rgba(120,113,108,0.07)]' : 'border-white/15 bg-white/[0.04] shadow-float'}`}>
          <div className="flex items-center justify-between gap-4">
            <h2 className={`text-xl font-black tracking-tight ${isLight ? 'text-stone-900' : 'text-white'}`}>
              {query.trim() ? 'Qidiruv natijalari' : "Do'stlar"}
            </h2>
            <div className={`inline-flex items-center gap-2 border px-3 py-1.5 text-xs font-bold uppercase tracking-[0.16em] ${isLight ? 'border-stone-200 bg-white text-stone-600' : 'border-white/15 bg-white/5 text-white/74'}`}>
              <Users2 className="h-4 w-4" />
              {list.length}
            </div>
          </div>

          {list.length === 0 ? (
            <div className={`mt-6 border border-dashed p-8 ${isLight ? 'border-stone-300 bg-[#fffaf4]' : 'border-white/18 bg-slate-950/40'}`}>
              <p className={`text-sm font-bold uppercase tracking-[0.16em] ${isLight ? 'text-stone-800' : 'text-white'}`}>
                {query.trim() ? 'Hech kim topilmadi' : "Do'stlar yo'q"}
              </p>
              <p className={`mt-3 text-sm leading-6 ${isLight ? 'text-stone-600' : 'text-white/64'}`}>
                {query.trim()
                  ? 'Boshqa username yoki ism bilan qidiring'
                  : "Username bo'yicha qidiring va do'st qo'shing"}
              </p>
            </div>
          ) : (
            <div className="mt-4 flex flex-col gap-px">
              {list.map((person) => {
                const name = person.displayName || person.username || ''
                const username = person.username || ''
                const isFriend = friends.some((f) => f.userId === person.id || f.id === person.id)
                return (
                  <div
                    key={person.id || person.userId}
                    className={`flex items-center justify-between gap-4 border px-4 py-4 ${isLight ? 'border-stone-200 bg-[#fffaf4]' : 'border-white/10 bg-[#060b12]'}`}
                  >
                    <div className="flex items-center gap-3 min-w-0">
                      <div className={`flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-full text-sm font-bold ${isLight ? 'bg-stone-200 text-stone-700' : 'bg-white/10 text-white'}`}>
                        {name.slice(0, 1).toUpperCase()}
                      </div>
                      <div className="min-w-0">
                        <p className={`truncate text-sm font-bold ${isLight ? 'text-stone-900' : 'text-white'}`}>{name}</p>
                        <p className={`text-xs ${isLight ? 'text-stone-500' : 'text-white/52'}`}>@{username}</p>
                      </div>
                    </div>
                    {!isFriend && query.trim() && (
                      <button
                        type="button"
                        onClick={() => handleAdd(username)}
                        disabled={sent[username]}
                        className={`flex-shrink-0 inline-flex items-center gap-1.5 border px-3 py-1.5 text-xs font-bold uppercase tracking-[0.12em] disabled:opacity-60 ${isLight ? 'border-stone-900 bg-stone-900 text-white' : 'border-white/30 bg-white/10 text-white'}`}
                      >
                        {sent[username] ? <Check className="h-3.5 w-3.5" /> : <UserPlus className="h-3.5 w-3.5" />}
                        {sent[username] ? "Yuborildi" : "Qo'sh"}
                      </button>
                    )}
                  </div>
                )
              })}
            </div>
          )}
        </section>
      </section>
    </main>
  )
}
