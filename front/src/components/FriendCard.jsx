import { Battery, MoonStar, Navigation } from 'lucide-react'

function getStatusChip(status) {
  if (status?.state === 'moving') {
    return {
      label: 'Moving',
      icon: Navigation,
      tone: 'bg-emerald-500/14 text-emerald-700',
    }
  }

  return {
    label: 'Sleeping',
    icon: MoonStar,
    tone: 'bg-slate-700/10 text-slate-700',
  }
}

export default function FriendCard({ friend, isSelected, onSelect }) {
  const chip = getStatusChip(friend.status)
  const StatusIcon = chip.icon

  return (
    <button
      type="button"
      onClick={() => onSelect(friend.id)}
      className={`w-full rounded-[1.75rem] border px-4 py-3 text-left transition ${
        isSelected
          ? 'border-white/60 bg-white/84 shadow-float'
          : 'border-white/35 bg-white/58 hover:bg-white/70'
      }`}
    >
      <div className="flex items-start gap-3">
        <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-[1.4rem] bg-gradient-to-br from-zenly-peach to-zenly-lemon text-sm font-black tracking-[0.22em] text-zenly-ink shadow-glow">
          {friend.avatar}
        </div>
        <div className="min-w-0 flex-1">
          <div className="flex items-start justify-between gap-3">
            <div>
              <p className="text-base font-bold text-zenly-ink">{friend.name}</p>
              <p className="text-xs text-zenly-ink/60">
                {friend.location.zone} / {friend.location.updatedAt}
              </p>
            </div>
            <span className="rounded-full bg-zenly-night px-2.5 py-1 text-[11px] font-semibold text-white">
              {friend.distanceKm} km
            </span>
          </div>

          <div className="mt-3 flex items-center gap-2 text-xs font-semibold">
            <span className={`inline-flex items-center gap-1 rounded-full px-2.5 py-1 ${chip.tone}`}>
              <StatusIcon className="h-3.5 w-3.5" />
              {chip.label}
            </span>
            <span className="inline-flex items-center gap-1 rounded-full bg-white/80 px-2.5 py-1 text-zenly-ink">
              <Battery className="h-3.5 w-3.5" />
              {friend.battery.level}%
              {friend.battery.charging ? ' charging' : ''}
            </span>
          </div>
        </div>
      </div>
    </button>
  )
}
