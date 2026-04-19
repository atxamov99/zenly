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

router.post(
  "/:friendId/messages",
  uploadMessageImage.single("image"),
  async (req, res, next) => {
    try {
      if (!mongoose.isValidObjectId(req.params.friendId)) {
        return res.status(400).json({ message: "Invalid friendId" });
      }
      const userId = req.user._id;
      const friendId = req.params.friendId;

      const friends = await ensureFriendship(userId, friendId);
      if (!friends) {
        return res.status(403).json({ message: "Not friends with this user" });
      }

      const type = req.body.type === "image" ? "image" : "text";
      const text = typeof req.body.text === "string" ? req.body.text : "";
      const imageUrl = req.file ? `/uploads/messages/${req.file.filename}` : "";

      if (type === "text" && !text.trim()) {
        return res.status(400).json({ message: "text required for text message" });
      }
      if (type === "image" && !imageUrl) {
        return res.status(400).json({ message: "image file required for image message" });
      }

      const conversation = await findOrCreateConversation(userId, friendId);
      const message = await Message.create({
        conversationId: conversation._id,
        senderId: userId,
        type,
        text: type === "text" ? text : "",
        imageUrl
      });

      const previewText = type === "text" ? text : "";
      const unread = conversation.unread || new Map();
      const friendUnread = (unread.get?.(friendId.toString()) ?? unread[friendId.toString()] ?? 0) + 1;

      conversation.lastMessage = {
        text: previewText,
        type,
        senderId: userId,
        createdAt: message.createdAt
      };
      conversation.lastMessageAt = message.createdAt;
      conversation.unread.set(friendId.toString(), friendUnread);
      await conversation.save();

      emitMessage(conversation.toObject(), message.toObject());

      res.status(201).json({ message, conversation });
    } catch (err) {
      next(err);
    }
  }
);

router.patch("/messages/:id", async (req, res, next) => {
  try {
    const id = req.params.id;
    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({ message: "Invalid message id" });
    }
    const newText = typeof req.body.text === "string" ? req.body.text.trim() : "";
    if (!newText) return res.status(400).json({ message: "text required" });

    const message = await Message.findById(id);
    if (!message) return res.status(404).json({ message: "Message not found" });
    if (message.senderId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "Not the sender" });
    }
    if (message.deletedAt) {
      return res.status(403).json({ message: "Cannot edit a deleted message" });
    }
    if (message.type !== "text") {
      return res.status(403).json({ message: "Only text messages are editable" });
    }
    const ageMs = Date.now() - new Date(message.createdAt).getTime();
    if (ageMs > 24 * 60 * 60 * 1000) {
      return res.status(403).json({ message: "Edit window has expired" });
    }

    message.text = newText;
    message.editedAt = new Date();
    await message.save();

    const conversation = await Conversation.findById(message.conversationId);
    emitEdited({
      participants: conversation.participants,
      messageId: message._id,
      text: message.text,
      editedAt: message.editedAt
    });

    res.json({ message });
  } catch (err) {
    next(err);
  }
});

router.delete("/messages/:id", async (req, res, next) => {
  try {
    const id = req.params.id;
    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({ message: "Invalid message id" });
    }
    const message = await Message.findById(id);
    if (!message) return res.status(404).json({ message: "Message not found" });
    if (message.senderId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "Not the sender" });
    }
    if (message.deletedAt) {
      return res.json({ message });
    }

    message.deletedAt = new Date();
    await message.save();

    const conversation = await Conversation.findById(message.conversationId);
    emitDeleted({
      participants: conversation.participants,
      messageId: message._id
    });

    res.json({ message });
  } catch (err) {
    next(err);
  }
});

router.post("/:friendId/read", async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.friendId)) {
      return res.status(400).json({ message: "Invalid friendId" });
    }
    const userId = req.user._id;
    const friendId = req.params.friendId;
    const conversation = await Conversation.findOne({
      participants: { $all: sortedPair(userId, friendId), $size: 2 }
    });
    if (!conversation) {
      return res.json({ updated: 0 });
    }

    const readAt = new Date();
    const result = await Message.updateMany(
      {
        conversationId: conversation._id,
        senderId: friendId,
        "readBy.userId": { $ne: userId }
      },
      { $push: { readBy: { userId, readAt } } }
    );

    conversation.unread.set(userId.toString(), 0);
    await conversation.save();

    emitRead({
      conversationId: conversation._id,
      readerId: userId,
      participants: conversation.participants,
      readAt
    });

    res.json({ updated: result.modifiedCount });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
