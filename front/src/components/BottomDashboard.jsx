import { Plus, MapPin, Clock3 } from 'lucide-react'

function formatLastSeen(timestamp) {
  const diffMinutes = Math.max(1, Math.round((Date.now() - timestamp) / 60000))
  if (diffMinutes < 60) return `${diffMinutes} min ago`
  return `${Math.round(diffMinutes / 60)} h ago`
}

function formatDistance(distanceKm) {
  if (distanceKm < 1) return `${Math.round(distanceKm * 1000)} m`
  return `${distanceKm.toFixed(1)} km`
}

export default function BottomDashboard({
  friends,
  favoriteFriends,
  selectedUserId,
  isExpanded,
  onToggle,
  onSelectFriend,
  onAddFriend,
}) {
  const hasFavorites = favoriteFriends.length > 0
  const hasFriends = friends.length > 0

  return (
    <section className="absolute inset-x-0 bottom-0 z-30 px-3 pb-3">
      <div
        className={`rounded-[2rem] border border-white/20 bg-white/10 shadow-float backdrop-blur-xl transition-all duration-300 ${
          isExpanded ? 'pt-4' : 'pt-3'
        }`}
      >
        <button
          type="button"
          onClick={onToggle}
          className="flex w-full items-center justify-center pb-3"
        >
          <span className="h-1.5 w-12 rounded-full bg-white/35" />
        </button>

        <div className="px-4 pb-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-xs uppercase tracking-[0.22em] text-white/60">Friends</p>
              <h2 className="mt-1 text-2xl font-black tracking-tight text-white">Radar</h2>
            </div>
            <button
              type="button"
              onClick={onAddFriend}
              className="inline-flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-slate-950 shadow-lg"
            >
              <Plus className="h-5 w-5" />
            </button>
          </div>

          {hasFavorites ? (
            <div className="mt-4 flex items-center gap-3">
              {favoriteFriends.map((friend) => (
                <button
                  key={friend.id}
                  type="button"
                  onClick={() => onSelectFriend(friend.id)}
                  className={`flex h-14 w-14 items-center justify-center rounded-full border text-sm font-black tracking-[0.18em] transition ${
                    selectedUserId === friend.id
                      ? 'border-transparent bg-gradient-to-br from-sky-400 to-fuchsia-500 text-slate-950'
                      : 'border-white/25 bg-white/10 text-white'
                  }`}
                >
                  {friend.avatar}
                </button>
              ))}
            </div>
          ) : (
            <div className="mt-4 rounded-[1.5rem] border border-dashed border-white/15 bg-slate-950/20 p-4 text-sm leading-6 text-white/68">
              No friends yet.
            </div>
          )}

          <div
            className={`grid transition-all duration-300 ${
              isExpanded ? 'mt-4 max-h-[23rem] opacity-100' : 'mt-0 max-h-0 opacity-0'
            } overflow-hidden`}
          >
            {hasFriends ? (
              <div className="space-y-3 overflow-y-auto pr-1">
                {friends.map((friend) => (
                  <button
                    key={friend.id}
                    type="button"
                    onClick={() => onSelectFriend(friend.id)}
                    className={`w-full rounded-[1.6rem] border px-4 py-4 text-left transition ${
                      selectedUserId === friend.id
                        ? 'border-sky-300/60 bg-white/16'
                        : 'border-white/12 bg-slate-950/18 hover:bg-white/12'
                    }`}
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="text-base font-bold text-white">{friend.name}</span>
                          <span className="rounded-full bg-white/10 px-2 py-1 text-[11px] font-semibold text-white/70">
                            @{friend.username}
                          </span>
                        </div>
                        <div className="mt-3 flex flex-wrap gap-2 text-xs text-white/72">
                          <span className="inline-flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-1">
                            <MapPin className="h-3.5 w-3.5" />
                            {friend.address}
                          </span>
                          <span className="inline-flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-1">
                            <Clock3 className="h-3.5 w-3.5" />
                            {formatLastSeen(friend.lastSeen)}
                          </span>
                        </div>
                      </div>

                      <div className="text-right">
                        <p className="text-sm font-bold text-white">{formatDistance(friend.distanceKm)}</p>
                        <p className="mt-2 text-xs text-white/60">{friend.status}</p>
                      </div>
                    </div>
                  </button>
                ))}
              </div>
            ) : (
              <div className="rounded-[1.6rem] border border-dashed border-white/15 bg-slate-950/20 p-5 text-sm leading-6 text-white/68">
                Nothing here yet.
              </div>
            )}
          </div>
        </div>
      </div>
    </section>
  )
}
