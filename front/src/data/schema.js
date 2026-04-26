export const friendSchema = {
  id: 'uuid',
  username: 'abdulloh_dev',
  coordinates: [41.311081, 69.240562],
  status: 'moving',
  battery: 88,
  isCharging: false,
  lastSeen: Date.now(),
}

export const currentUserSchema = {
  id: 'self',
  username: 'you',
  coordinates: [41.311081, 69.240562],
  status: 'ghost_mode',
  battery: 92,
  isCharging: false,
  lastSeen: Date.now(),
}
