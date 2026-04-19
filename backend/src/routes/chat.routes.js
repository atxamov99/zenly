// backend/src/routes/chat.routes.js
const express = require("express");
const mongoose = require("mongoose");

const auth = require("../middleware/auth");
const Conversation = require("../models/Conversation");
const Message = require("../models/Message");
const Friendship = require("../models/Friendship");
const { uploadMessageImage } = require("../config/upload");
const {
  emitMessage,
  emitRead,
  emitEdited,
  emitDeleted
} = require("../utils/chat-emit");

const router = express.Router();
router.use(auth);

function sortedPair(a, b) {
  return [a, b].map((id) => id.toString()).sort();
}

async function ensureFriendship(userIdA, userIdB) {
  const friendship = await Friendship.findOne({
    status: "accepted",
    $or: [
      { requester: userIdA, recipient: userIdB },
      { requester: userIdB, recipient: userIdA }
    ]
  });
  return Boolean(friendship);
}

async function findOrCreateConversation(userIdA, userIdB) {
  const sorted = sortedPair(userIdA, userIdB);
  const existing = await Conversation.findOne({ participants: { $all: sorted, $size: 2 } });
  if (existing) return existing;
  try {
    return await Conversation.create({ participants: sorted, unread: {} });
  } catch (err) {
    if (err.code === 11000) {
      return Conversation.findOne({ participants: { $all: sorted, $size: 2 } });
    }
    throw err;
  }
}

router.get("/", async (req, res, next) => {
  try {
    const userId = req.user._id;
    const conversations = await Conversation.find({ participants: userId })
      .sort({ lastMessageAt: -1 })
      .lean();
    res.json({ conversations });
  } catch (err) {
    next(err);
  }
});

router.get("/:friendId/messages", async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.friendId)) {
      return res.status(400).json({ message: "Invalid friendId" });
    }
    const userId = req.user._id;
    const friendId = req.params.friendId;
    const limit = Math.min(parseInt(req.query.limit, 10) || 30, 100);
    const before = req.query.before ? new Date(req.query.before) : null;

    const conversation = await Conversation.findOne({
      participants: { $all: sortedPair(userId, friendId), $size: 2 }
    });
    if (!conversation) {
      return res.json({ messages: [], conversation: null });
    }

    const filter = { conversationId: conversation._id };
    if (before) filter.createdAt = { $lt: before };

    const messages = await Message.find(filter)
      .sort({ createdAt: -1 })
      .limit(limit)
      .lean();

    res.json({ messages, conversation });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
