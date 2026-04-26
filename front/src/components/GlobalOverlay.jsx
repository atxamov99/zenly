import { useState } from 'react'
import { Focus, Globe, Search, Shield, UserCircle2 } from 'lucide-react'

export default function GlobalOverlay({
  currentUser,
  statusMode = 'Ghost Mode',
  onFocusSelf,
  onOpenProfile,
}) {
  const [isSearchOpen, setIsSearchOpen] = useState(false)

  return (
    <div className="pointer-events-none absolute inset-0 z-20">
      <div className="flex items-start justify-between px-4 pt-5">
        <div className="pointer-events-auto">
          <button
            type="button"
            onClick={() => setIsSearchOpen((value) => !value)}
            className={`flex h-12 items-center gap-3 rounded-2xl border border-white/20 bg-white/10 px-4 text-white shadow-float backdrop-blur-lg transition-all duration-300 ${
              isSearchOpen ? 'w-72' : 'w-12 justify-center px-0'
            }`}
          >
            <Search className="h-4 w-4 shrink-0" />
            <input
              type="text"
              placeholder="Search friends"
              className={`w-full bg-transparent text-sm outline-none placeholder:text-white/55 ${
                isSearchOpen ? 'opacity-100' : 'pointer-events-none w-0 opacity-0'
              }`}
              readOnly
            />
          </button>
        </div>

        <div className="pointer-events-auto inline-flex items-center gap-2 rounded-2xl border border-white/20 bg-white/10 px-4 py-3 text-sm font-semibold text-white shadow-float backdrop-blur-lg">
          <Shield className="h-4 w-4 text-emerald-300" />
          {statusMode}
        </div>
      </div>

      <div className="absolute inset-x-0 bottom-[11.5rem] flex items-end justify-between px-4">
        <button
          type="button"
          onClick={onOpenProfile}
          className="pointer-events-auto flex items-center gap-3 rounded-[1.35rem] border border-white/20 bg-white/10 px-3 py-3 text-left text-white shadow-float backdrop-blur-lg"
        >
          <span className="flex h-11 w-11 items-center justify-center rounded-full bg-gradient-to-br from-sky-400 to-fuchsia-500 text-sm font-black tracking-[0.2em] text-slate-950">
            {currentUser.avatar}
          </span>
          <span>
            <span className="block text-xs uppercase tracking-[0.18em] text-white/60">Me</span>
            <span className="block text-sm font-semibold">{currentUser.name}</span>
          </span>
        </button>

        <div className="pointer-events-auto flex flex-col gap-3">
          <button
            type="button"
            onClick={onFocusSelf}
            className="inline-flex h-12 w-12 items-center justify-center rounded-2xl border border-white/20 bg-white/10 text-white shadow-float backdrop-blur-lg transition hover:bg-white/15"
          >
            <Focus className="h-5 w-5" />
          </button>
          <button
            type="button"
            className="inline-flex h-12 w-12 items-center justify-center rounded-2xl border border-white/20 bg-white/10 text-white shadow-float backdrop-blur-lg transition hover:bg-white/15"
          >
            <Globe className="h-5 w-5" />
          </button>
        </div>
      </div>

      <div className="absolute left-4 top-24 pointer-events-none rounded-2xl border border-white/10 bg-slate-950/18 px-4 py-3 text-white/90 backdrop-blur-lg">
        <div className="flex items-center gap-2 text-xs uppercase tracking-[0.22em] text-white/60">
          <UserCircle2 className="h-4 w-4" />
          Zenly
        </div>
      </div>
    </div>
  )
}
