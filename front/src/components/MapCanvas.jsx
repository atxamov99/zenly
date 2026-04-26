import UserMarker from './UserMarker'

const MAP_BOUNDS = {
  minLat: 41.27,
  maxLat: 41.35,
  minLng: 69.22,
  maxLng: 69.34,
}

function toPercent([lat, lng]) {
  const x = ((lng - MAP_BOUNDS.minLng) / (MAP_BOUNDS.maxLng - MAP_BOUNDS.minLng)) * 100
  const y = 100 - ((lat - MAP_BOUNDS.minLat) / (MAP_BOUNDS.maxLat - MAP_BOUNDS.minLat)) * 100

  return {
    x: Math.max(8, Math.min(92, x)),
    y: Math.max(10, Math.min(90, y)),
  }
}

function createCameraTransform(flyTarget) {
  const { x, y } = toPercent(flyTarget)
  const moveX = 50 - x
  const moveY = 50 - y

  return `translate(${moveX}%, ${moveY}%) scale(1.08)`
}

export default function MapCanvas({
  currentUser,
  friends,
  selectedUserId,
  flyTarget,
  onSelectUser,
}) {
  return (
    <section className="absolute inset-0 z-0 overflow-hidden bg-[#071120]">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(70,108,255,0.34),transparent_32%),radial-gradient(circle_at_82%_18%,rgba(255,67,164,0.2),transparent_22%),linear-gradient(180deg,#071120_0%,#0d1730_38%,#14254b_100%)]" />
      <div className="absolute inset-0 bg-[linear-gradient(rgba(255,255,255,0.04)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.04)_1px,transparent_1px)] bg-[size:52px_52px]" />
      <div className="absolute inset-[5%] rounded-[3rem] border border-white/8 bg-[radial-gradient(circle_at_20%_20%,rgba(53,127,255,0.18),transparent_24%),radial-gradient(circle_at_70%_78%,rgba(255,67,164,0.16),transparent_24%),linear-gradient(180deg,rgba(255,255,255,0.05),rgba(255,255,255,0.01))]" />

      <div
        className="absolute inset-0 transition-transform duration-700 ease-out"
        style={{ transform: createCameraTransform(flyTarget), transformOrigin: '50% 50%' }}
      >
        <div className="absolute inset-0">
          {[currentUser, ...friends].map((person) => {
            const point = toPercent(person.coordinates)

            return (
              <UserMarker
                key={person.id}
                user={person}
                isSelected={person.id === selectedUserId}
                isCurrentUser={person.id === currentUser.id}
                onSelect={onSelectUser}
                positionStyle={{ left: `${point.x}%`, top: `${point.y}%` }}
              />
            )
          })}
        </div>
      </div>
    </section>
  )
}
