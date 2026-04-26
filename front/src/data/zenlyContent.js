export const places = [
  { name: 'Magic City', coordinates: [69.2447, 41.3045] },
  { name: 'Tashkent City', coordinates: [69.2452, 41.3156] },
  { name: 'Yunusabad', coordinates: [69.2884, 41.3664] },
  { name: 'Chilanzar', coordinates: [69.2019, 41.2757] },
  { name: 'Naberezhnaya', coordinates: [69.3132, 41.3098] },
]

export const peopleList = []

export function getFeedCards(t, city) {
  return [
    {
      title: t('feedCityTitle'),
      value: city || 'Tashkent',
      text: t('feedCityText'),
    },
    {
      title: t('feedLocationTitle'),
      value: t('feedLocationValue'),
      text: t('feedLocationText'),
    },
    {
      title: t('feedPointsTitle'),
      value: String(places.length),
      text: t('feedPointsText'),
    },
  ]
}

export function buildInitials(name, username) {
  const seed = (name || username || 'U').trim()

  return seed
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? '')
    .join('')
}

export function buildCurrentUserProfile(user) {
  return {
    id: user.id,
    name: user.name,
    handle: `@${user.username}`,
    initials: buildInitials(user.name, user.username),
    avatar: user.avatar || '',
    email: user.email || '',
    city: user.city || '',
    place: user.place || user.address || '',
    bio: user.bio || '',
    createdAt: user.createdAt || '',
    coordinates: user.coordinates || [69.2447, 41.3045],
  }
}
