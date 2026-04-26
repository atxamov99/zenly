export const appUsers = [
  {
    id: 'self',
    username: 'abdulloh_dev',
    name: 'Abdulloh',
    avatar: 'AD',
    email: 'abdulloh@example.com',
    coordinates: [41.311081, 69.240562],
    status: 'ghost_mode',
    battery: 92,
    isCharging: false,
    lastSeen: Date.now() - 60 * 1000,
    city: 'Tashkent',
    address: 'Mirabad district',
    bio: 'Building location-first products with clean UI.',
    role: 'You',
    mutualFriends: 0,
  },
]

export const currentUserTemplate = appUsers.find((user) => user.id === 'self')

export const friendIds = []

export const discoverableUserIds = []
