import { useMemo, useState } from 'react'
import { appUsers, currentUserTemplate, friendIds } from '../mockData/zenlyData'

export function useZenlyStore(authUser, initialSelectedId = 'self') {
  const [selectedUserId, setSelectedUserId] = useState(initialSelectedId)
  const [currentUser, setCurrentUser] = useState({
    ...currentUserTemplate,
    ...authUser,
  })
  const [friends, setFriends] = useState(
    appUsers.filter((user) => friendIds.includes(user.id)),
  )

  const selectedFriend = useMemo(
    () => friends.find((friend) => friend.id === selectedUserId) ?? null,
    [friends, selectedUserId],
  )

  const favoriteFriends = useMemo(
    () => friends.filter((friend) => friend.isFavorite).slice(0, 4),
    [friends],
  )

  const flyTarget = useMemo(() => {
    if (selectedFriend) {
      return selectedFriend.coordinates
    }

    return currentUser.coordinates
  }, [currentUser.coordinates, selectedFriend])

  const onLocationUpdate = (friendId, nextCoordinates) => {
    setFriends((current) =>
      current.map((friend) =>
        friend.id === friendId
          ? {
              ...friend,
              coordinates: nextCoordinates,
              lastSeen: Date.now(),
            }
          : friend,
      ),
    )
  }

  return {
    currentUser,
    setCurrentUser,
    friends,
    favoriteFriends,
    selectedFriend,
    selectedUserId,
    setSelectedUserId,
    flyTarget,
    onLocationUpdate,
    seedData: {
      currentUser: currentUserTemplate,
      friends: appUsers.filter((user) => friendIds.includes(user.id)),
    },
  }
}
