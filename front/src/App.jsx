import { useEffect, useMemo, useState } from 'react'
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { SUPPORTED_LOCALES, createTranslator } from './i18n/translations'
import AppLayout from './layouts/AppLayout'
import AddFriendsPage from './pages/AddFriendsPage'
import AuthPage from './pages/AuthPage'
import ProfilePage from './pages/ProfilePage'
import SettingsPage from './pages/SettingsPage'
import SetupProfilePage from './pages/SetupProfilePage'

const USERS_STORAGE_KEY = 'zenly_users'
const SESSION_STORAGE_KEY = 'zenly_session'
const THEME_STORAGE_KEY = 'zenly_theme'
const LOCALE_STORAGE_KEY = 'zenly_locale'

function readStoredUsers() {
  try {
    const raw = localStorage.getItem(USERS_STORAGE_KEY)
    return raw ? JSON.parse(raw) : []
  } catch {
    return []
  }
}

function readStoredSession() {
  try {
    const raw = localStorage.getItem(SESSION_STORAGE_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

function readStoredTheme() {
  try {
    const raw = localStorage.getItem(THEME_STORAGE_KEY)
    return raw === 'light' || raw === 'dark' ? raw : 'dark'
  } catch {
    return 'dark'
  }
}

function readStoredLocale() {
  try {
    const raw = localStorage.getItem(LOCALE_STORAGE_KEY)
    return SUPPORTED_LOCALES.includes(raw) ? raw : 'ru'
  } catch {
    return 'ru'
  }
}

export default function App() {
  const [users, setUsers] = useState([])
  const [sessionUser, setSessionUser] = useState(null)
  const [theme, setTheme] = useState('dark')
  const [locale, setLocale] = useState('ru')
  const t = useMemo(() => createTranslator(locale), [locale])

  useEffect(() => {
    setUsers(readStoredUsers())
    setSessionUser(readStoredSession())
    setTheme(readStoredTheme())
    setLocale(readStoredLocale())
  }, [])

  useEffect(() => {
    document.documentElement.dataset.theme = theme
    localStorage.setItem(THEME_STORAGE_KEY, theme)
  }, [theme])

  useEffect(() => {
    document.documentElement.lang = locale
    localStorage.setItem(LOCALE_STORAGE_KEY, locale)
  }, [locale])

  const handleToggleTheme = () => {
    setTheme((current) => (current === 'light' ? 'dark' : 'light'))
  }

  const handleChangeLocale = (nextLocale) => {
    if (!SUPPORTED_LOCALES.includes(nextLocale)) {
      return
    }

    setLocale(nextLocale)
  }

  const handleAuthenticate = (user, mode) => {
    if (mode === 'register') {
      const nextUsers = [...users, user]
      setUsers(nextUsers)
      localStorage.setItem(USERS_STORAGE_KEY, JSON.stringify(nextUsers))
    }

    setSessionUser(user)
    localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(user))
  }

  const handleUpdateCurrentUser = (updates) => {
    setSessionUser((current) => {
      if (!current) {
        return current
      }

      const nextUser = { ...current, ...updates }

      setUsers((currentUsers) => {
        const nextUsers = currentUsers.map((user) =>
          user.id === nextUser.id ? { ...user, ...updates } : user,
        )
        localStorage.setItem(USERS_STORAGE_KEY, JSON.stringify(nextUsers))
        return nextUsers
      })

      localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(nextUser))
      return nextUser
    })
  }

  const handleLogout = () => {
    setSessionUser(null)
    localStorage.removeItem(SESSION_STORAGE_KEY)
  }

  const commonUiProps = {
    locale,
    onChangeLocale: handleChangeLocale,
    theme,
    onToggleTheme: handleToggleTheme,
    t,
  }

  const needsSetup = sessionUser && sessionUser.setupComplete === false

  return (
    <BrowserRouter>
      <Routes>
        {sessionUser ? (
          needsSetup ? (
            <>
              <Route
                path="/setup-profile"
                element={
                  <SetupProfilePage
                    currentUser={sessionUser}
                    onComplete={handleUpdateCurrentUser}
                    {...commonUiProps}
                  />
                }
              />
              <Route path="*" element={<Navigate to="/setup-profile" replace />} />
            </>
          ) : (
            <>
              <Route
                path="/"
                element={
                  <AppLayout
                    currentUser={sessionUser}
                    onLogout={handleLogout}
                    onUpdateCurrentUser={handleUpdateCurrentUser}
                    {...commonUiProps}
                  />
                }
              />
              <Route
                path="/people"
                element={<AddFriendsPage currentUser={sessionUser} {...commonUiProps} />}
              />
              <Route
                path="/profile"
                element={
                  <ProfilePage
                    currentUser={sessionUser}
                    onLogout={handleLogout}
                    onUpdateCurrentUser={handleUpdateCurrentUser}
                    {...commonUiProps}
                  />
                }
              />
              <Route
                path="/settings"
                element={
                  <SettingsPage
                    currentUser={sessionUser}
                    onLogout={handleLogout}
                    {...commonUiProps}
                  />
                }
              />
              <Route path="/setup-profile" element={<Navigate to="/" replace />} />
              <Route path="/auth" element={<Navigate to="/" replace />} />
            </>
          )
        ) : (
          <>
            <Route
              path="/auth"
              element={<AuthPage onAuthenticate={handleAuthenticate} users={users} {...commonUiProps} />}
            />
            <Route path="*" element={<Navigate to="/auth" replace />} />
          </>
        )}
      </Routes>
    </BrowserRouter>
  )
}
