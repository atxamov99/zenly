import { Compass, LocateFixed, MapPinned } from 'lucide-react'
import UserMarker from './UserMarker'

const getMarkerPosition = (lat, lng) => {
  const x = 18 + ((lng - 69.2) / 0.18) * 62
  const y = 18 + ((41.37 - lat) / 0.09) * 62

  return {
    left: `${Math.max(12, Math.min(88, x))}%`,
    top: `${Math.max(10, Math.min(86, y))}%`,
  }
}

export default function MapContainer({
  friends,
  selectedUserId,
  onSelectUser,
  onLocationUpdate,
}) {
  const handleRecenter = () => {
    onLocationUpdate('you', {
      lat: 41.3124,
      lng: 69.2781,
      zone: 'Centered by GPS',
      isMoving: true,
    })
  }

  return (
    <section className="absolute inset-0 overflow-hidden">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_20%_15%,rgba(255,255,255,0.85),transparent_20%),radial-gradient(circle_at_80%_18%,rgba(255,226,122,0.55),transparent_18%),linear-gradient(180deg,#dff7ff_0%,#9ed9ff_45%,#579bf7_100%)]" />
      <div className="absolute inset-0 bg-[linear-gradient(rgba(255,255,255,0.12)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.12)_1px,transparent_1px)] bg-[size:44px_44px] opacity-60" />
      <div className="absolute left-[-10%] top-[14%] h-48 w-48 rounded-full bg-white/20 blur-3xl" />
      <div className="absolute bottom-[20%] right-[-8%] h-56 w-56 rounded-full bg-zenly-lemon/30 blur-3xl" />

      <div className="absolute inset-x-0 top-0 flex items-center justify-between px-4 pt-6">
        <div className="inline-flex items-center gap-2 rounded-full bg-white/66 px-4 py-2 text-xs font-semibold uppercase tracking-[0.22em] text-zenly-ink shadow-lg backdrop-blur-md">
          <MapPinned className="h-4 w-4" />
          Tashkent Live
        </div>
        <button
          type="button"
          onClick={handleRecenter}
          className="inline-flex h-11 w-11 items-center justify-center rounded-full bg-white/72 text-zenly-ink shadow-lg backdrop-blur-md"
        >
          <LocateFixed className="h-5 w-5" />
        </button>
      </div>

      <div className="absolute inset-0">
        {friends.map((friend) => (
          <UserMarker
            key={friend.id}
            user={friend}
            isSelected={friend.id === selectedUserId}
            onSelect={onSelectUser}
            positionStyle={getMarkerPosition(friend.location.lat, friend.location.lng)}
          />
        ))}
      </div>

      <div className="absolute bottom-40 left-4 rounded-3xl bg-white/64 px-4 py-3 text-left shadow-float backdrop-blur-md">
        <div className="mb-1 inline-flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.2em] text-zenly-ink/70">
          <Compass className="h-4 w-4" />
          Map pulse
        </div>
        <p className="max-w-40 text-sm font-semibold leading-5 text-zenly-ink">
          Friends update through a single `onLocationUpdate(userId, payload)` entrypoint.
        </p>
      </div>
    </section>
  )
}
