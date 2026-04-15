const { Server } = require("socket.io");
const jwt = require("jsonwebtoken");

const Friendship = require("../models/Friendship");
const User = require("../models/User");
const { canViewerAccessByRule } = require("../utils/visibility");

let io;
const onlineConnections = new Map();

async function getAcceptedFriendIds(userId) {
  const friendships = await Friendship.find({
    status: "accepted",
    $or: [{ requester: userId }, { recipient: userId }]
  }).select("requester recipient");

  return friendships.map((friendship) =>
    friendship.requester.toString() === userId.toString()
      ? friendship.recipient.toString()
      : friendship.requester.toString()
  );
}

async function broadcastPresence(user, isOnline) {
  const friendIds = await getAcceptedFriendIds(user._id);

  for (const friendId of friendIds) {
    const canSeeLastSeen = await canViewerAccessByRule({
      owner: user,
      viewerId: friendId,
      rule: user.privacy?.lastSeenVisibility,
      areFriends: true
    });

    io.to(`user:${friendId}`).emit("friend:presence_changed", {
      friendId: user._id.toString(),
      isOnline,
      lastSeenAt: canSeeLastSeen ? user.presence?.lastSeenAt || null : null,
      smartStatus: user.presence?.smartStatus || "offline"
    });
  }
}

function initSocket(server) {
  io = new Server(server, {
    cors: {
      origin: process.env.CORS_ORIGIN || "*"
    }
  });

  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth?.token;
      if (!token) {
        return next(new Error("Unauthorized"));
      }

      const payload = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(payload.userId).select("_id username displayName");
      if (!user) {
        return next(new Error("Unauthorized"));
      }

      socket.user = user;
      next();
    } catch (error) {
      next(new Error("Unauthorized"));
    }
  });

  io.on("connection", (socket) => {
    const userId = socket.user._id.toString();
    const count = onlineConnections.get(userId) || 0;
    onlineConnections.set(userId, count + 1);

    socket.join(`user:${userId}`);

    if (count === 0) {
      User.findByIdAndUpdate(
        userId,
        {
          "presence.isOnline": true,
          "presence.lastSeenAt": new Date(),
          "presence.smartStatus": "idle"
        },
        { new: true }
      )
        .then((user) => broadcastPresence(user, true))
        .catch((error) => console.error("Presence update failed", error));
    }

    socket.emit("socket:ready", {
      userId
    });

    socket.on("disconnect", () => {
      const currentCount = onlineConnections.get(userId) || 0;
      const nextCount = Math.max(currentCount - 1, 0);

      if (nextCount === 0) {
        onlineConnections.delete(userId);

        User.findByIdAndUpdate(
          userId,
          {
            "presence.isOnline": false,
            "presence.lastSeenAt": new Date(),
            "presence.smartStatus": "offline"
          },
          { new: true }
        )
          .then((user) => broadcastPresence(user, false))
          .catch((error) => console.error("Presence update failed", error));
      } else {
        onlineConnections.set(userId, nextCount);
      }
    });
  });

  return io;
}

function getIo() {
  if (!io) {
    throw new Error("Socket.IO is not initialized");
  }

  return io;
}

module.exports = initSocket;
module.exports.getIo = getIo;
