// backend/src/utils/chat-emit.js
// Lazy getter to avoid circular dependency with sockets/index.js
function getIo() {
  return require("../sockets").getIo();
}

function toRoom(userId) {
  return `user:${userId.toString()}`;
}

function emitToParticipants(participants, event, payload) {
  const io = getIo();
  for (const userId of participants) {
    io.to(toRoom(userId)).emit(event, payload);
  }
}

function emitMessage(conversation, message) {
  emitToParticipants(conversation.participants, "chat:message", {
    message,
    conversation
  });
}

function emitRead({ conversationId, readerId, participants, readAt }) {
  emitToParticipants(participants, "chat:read", {
    conversationId: conversationId.toString(),
    friendId: readerId.toString(),
    readAt
  });
}

function emitTyping({ writerId, recipientId, isTyping }) {
  getIo().to(toRoom(recipientId)).emit("chat:typing", {
    friendId: writerId.toString(),
    isTyping
  });
}

function emitEdited({ participants, messageId, text, editedAt }) {
  emitToParticipants(participants, "chat:edited", {
    messageId: messageId.toString(),
    text,
    editedAt
  });
}

function emitDeleted({ participants, messageId }) {
  emitToParticipants(participants, "chat:deleted", {
    messageId: messageId.toString()
  });
}

module.exports = {
  emitMessage,
  emitRead,
  emitTyping,
  emitEdited,
  emitDeleted
};
