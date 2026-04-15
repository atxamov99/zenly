const Notification = require("../models/Notification");
const { getIo } = require("../sockets");

async function createNotification({ userId, type, title, body, data = {} }) {
  const notification = await Notification.create({
    user: userId,
    type,
    title,
    body,
    data
  });

  try {
    const io = getIo();
    io.to(`user:${userId.toString()}`).emit("notification:new", {
      notification
    });
  } catch (error) {
    if (error.message !== "Socket.IO is not initialized") {
      throw error;
    }
  }

  return notification;
}

module.exports = {
  createNotification
};
