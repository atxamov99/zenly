# Blink Clone Backend

Учебный `Node.js`-бэкенд для шаринга геолокации между друзьями.

## Стек

- `Express`
- `MongoDB + Mongoose`
- `JWT`
- `Socket.IO`

## Запуск

1. Создай `.env` на основе `.env.example`
2. Укажи:
   - `MONGODB_URI`
   - `JWT_SECRET`
3. Установи зависимости:

```bash
npm install
```

4. Запусти сервер:

```bash
npm run dev
```

## REST API

### Auth

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `GET /api/auth/me`
- `GET /api/auth/sessions`
- `POST /api/auth/change-password`
- `POST /api/auth/forgot-password`
- `POST /api/auth/reset-password`
- `POST /api/auth/logout`
- `POST /api/auth/logout-all`
- `DELETE /api/auth/sessions/:sessionId`

### Profile

- `PATCH /api/profile`
- `POST /api/profile/avatar`
- `PATCH /api/profile/privacy`

### Blocks

- `GET /api/blocks`
- `POST /api/blocks/:userId`
- `DELETE /api/blocks/:userId`

### Circles

- `GET /api/circles`
- `POST /api/circles`
- `PATCH /api/circles/:circleId`
- `DELETE /api/circles/:circleId`
- `POST /api/circles/:circleId/members`
- `DELETE /api/circles/:circleId/members/:memberId`

### Friends

- `GET /api/friends/search?q=alex`
- `GET /api/friends`
- `GET /api/friends/requests`
- `POST /api/friends/request`
- `PATCH /api/friends/:requestId/respond`
- `DELETE /api/friends/request/:requestId`
- `DELETE /api/friends/:friendId`

### Location

- `POST /api/location/update`
- `POST /api/location/share/:friendId`
- `DELETE /api/location/share/:friendId`
- `GET /api/location/visible-friends`
- `GET /api/location/history`
- `GET /api/location/history/:friendId`
- `GET /api/location/share-settings`

### Geozones

- `GET /api/geozones`
- `POST /api/geozones`
- `PATCH /api/geozones/:geozoneId`
- `DELETE /api/geozones/:geozoneId`
- `POST /api/geozones/:geozoneId/viewers`
- `DELETE /api/geozones/:geozoneId/viewers/:viewerId`

### Invites

- `GET /api/invites`
- `POST /api/invites`
- `POST /api/invites/use/:code`
- `DELETE /api/invites/:inviteId`

### Notifications

- `GET /api/notifications`
- `PATCH /api/notifications/:notificationId/read`
- `PATCH /api/notifications/read-all`

### Push

- `GET /api/push/tokens`
- `POST /api/push/tokens`
- `DELETE /api/push/tokens/:tokenId`

## Socket.IO

Подключение:

```js
const socket = io("http://localhost:4000", {
  auth: {
    token: "JWT_TOKEN"
  }
});
```

События:

- `socket:ready`
- `friend:location_changed`
- `friend:presence_changed`
- `friend:geozone_event`
- `friend:smart_status_changed`
- `notification:new`

## Пример тела запросов

Регистрация:

```json
{
  "username": "alex",
  "email": "alex@example.com",
  "password": "12345678",
  "displayName": "Alex"
}
```

Обновление локации:

```json
{
  "lat": 41.311081,
  "lng": 69.240562,
  "accuracy": 15
}
```

Обновление профиля:

```json
{
  "username": "alex",
  "email": "alex@example.com",
  "displayName": "Alex",
  "avatarUrl": "https://example.com/avatar.jpg"
}
```

Загрузка аватарки файлом:

`POST /api/profile/avatar`

`multipart/form-data`

- поле файла: `avatar`

Настройки приватности:

```json
{
  "locationVisibility": "circles",
  "lastSeenVisibility": "friends",
  "ghostMode": false
}
```

Временный шаринг локации:

```json
{
  "durationMinutes": 60
}
```

Создание круга:

```json
{
  "name": "Close Friends"
}
```

Создание геозоны:

```json
{
  "name": "Home",
  "kind": "home",
  "lat": 41.311081,
  "lng": 69.240562,
  "radiusMeters": 150,
  "notifyViewerIds": ["USER_ID"]
}
```

Умные статусы:

- `home`
- `study`
- `work`
- `on_the_way`
- `idle`
- `offline`

Создание инвайт-ссылки:

```json
{
  "expiresInHours": 24,
  "maxUses": 3
}
```

Сохранение push-токена:

```json
{
  "token": "device-token",
  "platform": "android"
}
```

## Быстрый сценарий теста

1. Зарегистрируй двух пользователей через `POST /api/auth/register`
2. Выполни логин и сохрани `token`
3. Найди друга через `GET /api/friends/search?q=...`
4. Отправь заявку через `POST /api/friends/request`
5. Со второго аккаунта прими заявку через `PATCH /api/friends/:requestId/respond`
6. Включи шаринг через `POST /api/location/share/:friendId`
7. Отправь координаты через `POST /api/location/update`
8. Получи видимых друзей через `GET /api/location/visible-friends`

## Примеры curl

Регистрация:

```bash
curl -X POST http://localhost:4000/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"alex\",\"email\":\"alex@example.com\",\"password\":\"12345678\",\"displayName\":\"Alex\"}"
```

Поиск пользователя:

```bash
curl "http://localhost:4000/api/friends/search?q=alex" ^
  -H "Authorization: Bearer JWT_TOKEN"
```

Отправка заявки в друзья:

```bash
curl -X POST http://localhost:4000/api/friends/request ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer JWT_TOKEN" ^
  -d "{\"username\":\"alex\"}"
```

Обновление локации:

```bash
curl -X POST http://localhost:4000/api/location/update ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer JWT_TOKEN" ^
  -d "{\"lat\":41.311081,\"lng\":69.240562,\"accuracy\":15}"
```

## Auth Notes

- Auth responses now return `accessToken`, `refreshToken`, `sessionId`, and `user`
- Swagger UI: `GET /api/docs`
- OpenAPI JSON: `GET /api/docs.json`

Change password:

```json
{
  "currentPassword": "12345678",
  "newPassword": "123456789"
}
```

Refresh token:

```json
{
  "refreshToken": "REFRESH_TOKEN"
}
```

Reset password:

```json
{
  "token": "RESET_TOKEN",
  "newPassword": "123456789"
}
```
