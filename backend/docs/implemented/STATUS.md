# Implemented

## Core

- Express server
- MongoDB via Mongoose
- env-based config
- static file serving for uploaded avatars
- Socket.IO realtime

## Auth

- register
- login
- access/refresh token flow
- current user endpoint
- sessions list
- logout current session
- logout all sessions
- revoke one session
- change password
- forgot password token generation
- reset password by token
- auth rate limiting

## Profile

- update username
- update email
- update display name
- update avatarUrl
- upload avatar file to local storage
- privacy settings

## Social

- friend requests
- accept/decline request
- cancel outgoing request
- search users
- friends list
- remove friend
- block/unblock users
- invite links
- circles

## Location

- share location with specific friends
- expiring location shares
- current location update
- location history
- visible friends feed
- geozones
- ghost mode
- smart statuses: `home`, `study`, `work`, `on_the_way`, `idle`, `offline`
- geozone notifications

## Notifications

- in-app notifications
- mark one as read
- mark all as read

## API Tooling

- Postman collection
- Swagger UI
- OpenAPI JSON
