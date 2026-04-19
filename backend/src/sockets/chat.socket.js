// backend/src/sockets/chat.socket.js
const { emitTyping } = require("../utils/chat-emit");

function registerChatHandlers(socket) {
  const userId = socket.user._id;

  socket.on("chat:typing_start", (payload = {}) => {
    if (!payload.friendId) return;
    emitTyping({ writerId: userId, recipientId: payload.friendId, isTyping: true });
  });

  socket.on("chat:typing_stop", (payload = {}) => {
    if (!payload.friendId) return;
    emitTyping({ writerId: userId, recipientId: payload.friendId, isTyping: false });
  });
}

module.exports = { registerChatHandlers };
