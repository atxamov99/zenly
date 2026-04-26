const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000'

async function request(path, options = {}) {
  const token = localStorage.getItem('blink_token')
  const res = await fetch(`${BASE_URL}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options.headers,
    },
  })
  const data = await res.json().catch(() => ({}))
  if (!res.ok) throw new Error(data.message || `Error ${res.status}`)
  return data
}

export const api = {
  register: (body) =>
    request('/auth/register', { method: 'POST', body: JSON.stringify(body) }),

  login: (body) =>
    request('/auth/login', { method: 'POST', body: JSON.stringify(body) }),

  logout: () =>
    request('/auth/logout', { method: 'POST' }),

  me: () => request('/auth/me'),

  getProfile: () => request('/profile'),

  updateProfile: (body) =>
    request('/profile', { method: 'PUT', body: JSON.stringify(body) }),

  getFriends: () => request('/friends'),

  searchUsers: (q) =>
    request(`/friends/search?q=${encodeURIComponent(q)}`),

  sendFriendRequest: (username) =>
    request('/friends/request', { method: 'POST', body: JSON.stringify({ username }) }),

  getConversations: () => request('/chat'),
}
