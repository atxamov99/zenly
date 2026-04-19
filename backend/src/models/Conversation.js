// backend/src/models/Conversation.js
const mongoose = require("mongoose");

const conversationSchema = new mongoose.Schema(
  {
    participants: {
      type: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
      required: true,
      validate: (v) => Array.isArray(v) && v.length >= 2
    },
    lastMessage: {
      text: { type: String, default: "" },
      type: { type: String, enum: ["text", "image"], default: "text" },
      senderId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
      createdAt: { type: Date }
    },
    lastMessageAt: { type: Date, index: true },
    unread: { type: Map, of: Number, default: {} }
  },
  { timestamps: true }
);

// Unique compound index on sorted participants — guarantees a single
// conversation document per pair, regardless of insert order.
conversationSchema.index({ participants: 1 }, { unique: true });

module.exports = mongoose.model("Conversation", conversationSchema);
