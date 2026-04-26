import { Bolt, Home, MoonStar, Navigation, School } from 'lucide-react'

const RADIUS = 22
const CIRCUMFERENCE = 2 * Math.PI * RADIUS

function getBatteryColor(level) {
  if (level > 70) return '#3DFFAE'
  if (level > 35) return '#75B7FF'
  if (level > 20) return '#FFC857'
  return '#FF4D6D'
}

function getBadge(user) {
  if (user.isCharging) {
    return { icon: Bolt, label: 'Charging', tone: 'bg-emerald-400 text-slate-950' }
  }

  switch (user.status) {
    case 'at_home':
      return { icon: Home, label: 'Home', tone: 'bg-white text-slate-950' }
    case 'sleeping':
      return { icon: MoonStar, label: 'Sleeping', tone: 'bg-slate-800 text-white' }
    case 'at_school':
      return { icon: School, label: 'School', tone: 'bg-sky-400 text-slate-950' }
    default:
      return { icon: Navigation, label: 'Moving', tone: 'bg-pink-500 text-white' }
  }
}

function getMarkerGlow(isCurrentUser, isSelected) {
  if (isCurrentUser) {
    return 'from-sky-400 via-blue-500 to-fuchsia-500'
  }

  if (isSelected) {
    return 'from-fuchsia-500 via-pink-500 to-sky-400'
  }

  return 'from-white/90 via-slate-200 to-slate-300'
}

export default function UserMarker({
  user,
  positionStyle,
  isSelected,
  isCurrentUser = false,
  onSelect,
}) {
  const dashOffset = CIRCUMFERENCE - (Math.max(0, Math.min(100, user.battery)) / 100) * CIRCUMFERENCE
  const badge = getBadge(user)
  const BadgeIcon = badge.icon

  return (
    <button
      type="button"
      style={positionStyle}
      onClick={() => !isCurrentUser && onSelect(user.id)}
      className="group absolute -translate-x-1/2 -translate-y-1/2 text-left transition-transform duration-300 hover:z-20 hover:scale-[1.03]"
    >
      <span className="relative block">
        <span
          className={`absolute inset-[-8px] rounded-full bg-gradient-to-br ${getMarkerGlow(
            isCurrentUser,
            isSelected,
          )} opacity-30 blur-md transition-opacity duration-300 ${isSelected ? 'opacity-70' : ''}`}
        />

        <span className="relative flex h-[72px] w-[72px] items-center justify-center">
          <svg
            className="-rotate-90 absolute inset-0 h-full w-full"
            viewBox="0 0 56 56"
            aria-hidden="true"
          >
            <circle
              cx="28"
              cy="28"
              r={RADIUS}
              fill="transparent"
              stroke="rgba(255,255,255,0.14)"
              strokeWidth="4"
            />
            <circle
              cx="28"
              cy="28"
              r={RADIUS}
              fill="transparent"
              stroke={getBatteryColor(user.battery)}
              strokeLinecap="round"
              strokeWidth="4"
              strokeDasharray={CIRCUMFERENCE}
              strokeDashoffset={dashOffset}
              className="transition-all duration-500"
            />
          </svg>

          <span className="absolute inset-[8px] rounded-full border border-white/20 bg-slate-950/80 backdrop-blur-lg" />
          <span
            className={`absolute inset-[11px] rounded-full bg-gradient-to-br ${getMarkerGlow(
              isCurrentUser,
              isSelected,
            )} p-[2px] shadow-[0_10px_30px_rgba(0,0,0,0.28)]`}
          >
            <span className="flex h-full w-full items-center justify-center rounded-full bg-slate-950 text-sm font-black tracking-[0.24em] text-white">
              {user.avatar}
            </span>
          </span>

          <span className={`absolute -right-1 bottom-1 inline-flex h-6 min-w-6 items-center justify-center rounded-full px-1.5 text-[10px] font-bold ${badge.tone}`}>
            <BadgeIcon className="h-3.5 w-3.5" />
          </span>

          {isCurrentUser ? (
            <span className="absolute -left-1 -top-1 h-3 w-3 rounded-full bg-emerald-400 ring-4 ring-emerald-400/20" />
          ) : null}
        </span>

        <span className="mt-2 flex flex-col items-center">
          <span className="rounded-full bg-slate-950/56 px-3 py-1 text-xs font-semibold text-white shadow-[0_10px_24px_rgba(0,0,0,0.32)] backdrop-blur-md">
            {user.name}
          </span>
          <span className="mt-1 text-[11px] font-semibold text-white/80 [text-shadow:0_2px_12px_rgba(0,0,0,0.55)]">
            {user.battery}% battery
          </span>
        </span>
      </span>
    </button>
  )
}
