// backend/src/models/Conversation.js
const mongoose = require("mongoose");

const conversationSchema = new mongoose.Schema(
  {
    isGroup: { type: Boolean, default: false, index: true },
    title: { type: String, default: "", trim: true, maxlength: 80 },
    avatarUrl: { type: String, default: "" },
    ownerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null
    },
    adminIds: {
      type: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
      default: []
    },
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

// Unique compound index for DMs only — multiple groups with the same
// members are allowed, but only one DM per pair.
conversationSchema.index(
  { participants: 1 },
  { unique: true, partialFilterExpression: { isGroup: false } }
);

module.exports = mongoose.model("Conversation", conversationSchema);
