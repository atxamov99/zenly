import FriendCard from './FriendCard'

export default function FriendList({ friends, selectedUserId, onSelect }) {
  return (
    <section className="absolute inset-x-0 bottom-24 z-20 px-4">
      <div className="rounded-[2rem] border border-white/35 bg-white/20 p-3 shadow-float backdrop-blur-xl">
        <div className="mb-3 flex items-center justify-between px-1">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.22em] text-white/75">
              Friend radar
            </p>
            <h2 className="text-lg font-bold text-white">Nearby right now</h2>
          </div>
          <span className="rounded-full bg-white/18 px-3 py-1 text-xs font-semibold text-white">
            {friends.length} online
          </span>
        </div>

        <div className="flex max-h-72 flex-col gap-3 overflow-y-auto pr-1">
          {friends.map((friend) => (
            <FriendCard
              key={friend.id}
              friend={friend}
              isSelected={friend.id === selectedUserId}
              onSelect={onSelect}
            />
          ))}
        </div>
      </div>
    </section>
  )
}
