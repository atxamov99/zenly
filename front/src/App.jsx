import { useEffect, useMemo, useState } from 'react'
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { SUPPORTED_LOCALES, createTranslator } from './i18n/translations'
import AppLayout from './layouts/AppLayout'
import AddFriendsPage from './pages/AddFriendsPage'
import AuthPage from './pages/AuthPage'
import ProfilePage from './pages/ProfilePage'
import SettingsPage from './pages/SettingsPage'
import SetupProfilePage from './pages/SetupProfilePage'
import { api } from './services/api'
import { connectSocket, disconnectSocket } from './services/socket'

const THEME_STORAGE_KEY = 'zenly_theme'
const LOCALE_STORAGE_KEY = 'zenly_locale'

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
  const [sessionUser, setSessionUser] = useState(null)
  const [authLoading, setAuthLoading] = useState(true)
  const [theme, setTheme] = useState('dark')
  const [locale, setLocale] = useState('ru')
  const t = useMemo(() => createTranslator(locale), [locale])

  useEffect(() => {
    setTheme(readStoredTheme())
    setLocale(readStoredLocale())

    const token = localStorage.getItem('blink_token')
    if (!token) {
      setAuthLoading(false)
      return
    }

    api.me()
      .then(({ user }) => {
        setSessionUser(user)
        connectSocket(token)
      })
      .catch(() => {
        localStorage.removeItem('blink_token')
        localStorage.removeItem('blink_refresh_token')
      })
      .finally(() => setAuthLoading(false))
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
    if (!SUPPORTED_LOCALES.includes(nextLocale)) return
    setLocale(nextLocale)
  }

  const handleAuthenticate = async (formData, mode) => {
    const body =
      mode === 'register'
        ? {
            username: formData.username,
            email: formData.email,
            password: formData.password,
            displayName: formData.name,
          }
        : { email: formData.email, password: formData.password }

    const endpoint = mode === 'register' ? 'register' : 'login'
    const { accessToken, refreshToken, user } = await api[endpoint](body)

    localStorage.setItem('blink_token', accessToken)
    if (refreshToken) localStorage.setItem('blink_refresh_token', refreshToken)

    setSessionUser(user)
    connectSocket(accessToken)
  }

  const handleUpdateCurrentUser = async (updates) => {
    try {
      const { user } = await api.updateProfile(updates)
      setSessionUser(user)
    } catch {
      setSessionUser((current) => (current ? { ...current, ...updates } : current))
    }
  }

  const handleLogout = async () => {
    try {
      await api.logout()
    } catch {}
    disconnectSocket()
    localStorage.removeItem('blink_token')
    localStorage.removeItem('blink_refresh_token')
    setSessionUser(null)
  }

  if (authLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-950">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-white/20 border-t-white" />
      </div>
    )
  }

  const commonUiProps = {
    locale,
    onChangeLocale: handleChangeLocale,
    theme,
    onToggleTheme: handleToggleTheme,
    t,
  }

  const needsSetup = sessionUser && !sessionUser.displayName

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
              element={<AuthPage onAuthenticate={handleAuthenticate} {...commonUiProps} />}
            />
            <Route path="*" element={<Navigate to="/auth" replace />} />
          </>
        )}
      </Routes>
    </BrowserRouter>
  )
}
