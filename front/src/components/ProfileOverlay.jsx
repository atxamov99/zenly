import { Battery, MapPin, MoonStar, Navigation, X } from 'lucide-react'

export default function ProfileOverlay({ user, onClose }) {
  if (!user) {
    return null
  }

  const isMoving = user.status?.state === 'moving'

  return (
    <div className="absolute inset-0 z-40 flex items-end bg-zenly-night/20 px-4 pb-24 pt-20 backdrop-blur-xs">
      <div className="w-full animate-rise rounded-[2rem] bg-white/86 p-5 text-zenly-ink shadow-float backdrop-blur-xl">
        <div className="mb-4 flex items-start justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="flex h-20 w-20 items-center justify-center rounded-[1.8rem] bg-gradient-to-br from-zenly-peach via-zenly-lemon to-white text-lg font-black tracking-[0.3em] shadow-glow">
              {user.avatar}
            </div>
            <div>
              <p className="text-2xl font-black tracking-tight">{user.name}</p>
              <p className="text-sm text-zenly-ink/65">{user.username}</p>
              <p className="mt-2 text-sm font-medium text-zenly-ink/80">{user.mood}</p>
            </div>
          </div>

          <button
            type="button"
            onClick={onClose}
            className="inline-flex h-10 w-10 items-center justify-center rounded-full bg-slate-100 text-zenly-ink"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="grid grid-cols-2 gap-3">
          <div className="rounded-[1.5rem] bg-zenly-mist p-4">
            <p className="text-xs font-semibold uppercase tracking-[0.2em] text-zenly-ink/50">
              Status
            </p>
            <div className="mt-2 flex items-center gap-2 text-sm font-bold">
              {isMoving ? <Navigation className="h-4 w-4" /> : <MoonStar className="h-4 w-4" />}
              {isMoving ? 'Moving' : 'Sleeping'}
            </div>
            <p className="mt-1 text-sm text-zenly-ink/65">{user.status?.label}</p>
          </div>

          <div className="rounded-[1.5rem] bg-zenly-mist p-4">
            <p className="text-xs font-semibold uppercase tracking-[0.2em] text-zenly-ink/50">
              Battery
            </p>
            <div className="mt-2 flex items-center gap-2 text-sm font-bold">
              <Battery className="h-4 w-4" />
              {user.battery.level}% {user.battery.charging ? 'charging' : 'left'}
            </div>
            <p className="mt-1 text-sm text-zenly-ink/65">Backend-ready battery entity</p>
          </div>
        </div>

        <div className="mt-3 rounded-[1.5rem] bg-gradient-to-r from-zenly-ocean to-zenly-sky p-4 text-white">
          <p className="text-xs font-semibold uppercase tracking-[0.2em] text-white/70">
            Last location
          </p>
          <div className="mt-2 flex items-center gap-2 text-base font-bold">
            <MapPin className="h-4 w-4" />
            {user.location.zone}
          </div>
          <p className="mt-1 text-sm text-white/85">
            {user.city} / updated {user.location.updatedAt}
          </p>
        </div>
      </div>
    </div>
  )
}
