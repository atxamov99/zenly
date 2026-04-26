import { Bell, MessageCircleMore, Search, UserRound } from 'lucide-react'

const navItems = [
  { id: 'map', label: 'Map', icon: Search, active: true },
  { id: 'chat', label: 'Chat', icon: MessageCircleMore },
  { id: 'alerts', label: 'Alerts', icon: Bell },
  { id: 'profile', label: 'Profile', icon: UserRound },
]

export default function BottomNavigation() {
  return (
    <nav className="absolute inset-x-0 bottom-0 z-30 px-4 pb-5">
      <div className="flex items-center justify-between rounded-[2rem] border border-white/40 bg-zenly-night/82 px-4 py-3 shadow-float backdrop-blur-xl">
        {navItems.map((item) => {
          const Icon = item.icon

          return (
            <button
              key={item.id}
              type="button"
              className={`flex min-w-16 flex-col items-center gap-1 rounded-2xl px-3 py-2 text-xs font-semibold transition ${
                item.active ? 'bg-white text-zenly-night' : 'text-white/72'
              }`}
            >
              <Icon className="h-4 w-4" />
              {item.label}
            </button>
          )
        })}
      </div>
    </nav>
  )
}
