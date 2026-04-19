// backend/src/models/Message.js
const mongoose = require("mongoose");

const messageSchema = new mongoose.Schema(
  {
    conversationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Conversation",
      required: true,
      index: true
    },
    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    type: { type: String, enum: ["text", "image"], required: true },
    text: { type: String, default: "" },
    imageUrl: { type: String, default: "" },
    editedAt: { type: Date, default: null },
    deletedAt: { type: Date, default: null },
    readBy: [
      {
        userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
        readAt: { type: Date, default: Date.now }
      }
    ]
  },
  { timestamps: true } // adds createdAt + updatedAt; createdAt is sort key
);

messageSchema.index({ conversationId: 1, createdAt: -1 });

module.exports = mongoose.model("Message", messageSchema);
