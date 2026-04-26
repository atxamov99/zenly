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

function toObjectId(id) {
  return new mongoose.Types.ObjectId(id.toString());
}

function sortedPair(a, b) {
  const idA = toObjectId(a);
  const idB = toObjectId(b);
  return [idA, idB].sort((x, y) =>
    x.toString().localeCompare(y.toString())
  );
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
  const query = {
    isGroup: false,
    participants: { $all: sorted, $size: 2 }
  };

  const existing = await Conversation.findOne(query);
  if (existing) return existing;

  try {
    const created = await Conversation.create({
      isGroup: false,
      participants: sorted,
      unread: {}
    });
    return created;
  } catch (err) {
    if (err.code === 11000) {
      return await Conversation.findOne(query);
    }
    throw err;
  }
}

router.get("/", async (req, res, next) => {
  try {
    const userId = req.user._id;
    const conversations = await Conversation.find({ participants: userId })
      .populate(
        "participants",
        "username displayName avatarUrl presence"
      )
      .sort({ lastMessageAt: -1 })
      .lean();
    res.json({ conversations });
  } catch (err) {
    next(err);
  }
});

// ─── Group chat endpoints ────────────────────────────────────────────

router.post("/groups", async (req, res, next) => {
  try {
    const { title, memberIds } = req.body;
    if (typeof title !== "string" || !title.trim()) {
      return res.status(400).json({ message: "title required" });
    }
    if (!Array.isArray(memberIds) || memberIds.length < 1) {
      return res.status(400).json({ message: "at least one memberId required" });
    }
    const normalized = memberIds
      .filter((id) => mongoose.isValidObjectId(id))
      .map((id) => id.toString());
    const userIdStr = req.user._id.toString();
    const participants = Array.from(new Set([userIdStr, ...normalized]));
    if (participants.length < 2) {
      return res.status(400).json({ message: "need >=2 participants" });
    }

    // All non-self members must be friends with creator.
    for (const memberId of normalized) {
      if (memberId === userIdStr) continue;
      const ok = await Friendship.findOne({
        status: "accepted",
        $or: [
          { requester: userIdStr, recipient: memberId },
          { requester: memberId, recipient: userIdStr }
        ]
      });
      if (!ok) {
        return res
          .status(403)
          .json({ message: `Not friends with ${memberId}` });
      }
    }

    const conv = await Conversation.create({
      isGroup: true,
      title: title.trim(),
      ownerId: req.user._id,
      adminIds: [req.user._id],
      participants,
      unread: {}
    });

    const populated = await Conversation.findById(conv._id)
      .populate(
        "participants",
        "username displayName avatarUrl presence"
      )
      .lean();

    // Notify all members so their chat list updates.
    const io = require("../sockets").getIo();
    for (const userId of participants) {
      io.to(`user:${userId}`).emit("chat:group_created", {
        conversation: populated
      });
    }

    res.status(201).json({ conversation: populated });
  } catch (err) {
    next(err);
  }
});

router.get("/groups/:id/messages", async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ message: "Invalid conversation id" });
    }
    const userId = req.user._id;
    const limit = Math.min(parseInt(req.query.limit, 10) || 30, 100);
    const before = req.query.before ? new Date(req.query.before) : null;

    const conversation = await Conversation.findOne({
      _id: req.params.id,
      isGroup: true,
      participants: userId
    });
    if (!conversation) {
      return res.status(404).json({ message: "Group not found" });
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
  "/groups/:id/messages",
  uploadMessageImage.single("image"),
  async (req, res, next) => {
    try {
      if (!mongoose.isValidObjectId(req.params.id)) {
        return res.status(400).json({ message: "Invalid conversation id" });
      }
      const userId = req.user._id;
      const conversation = await Conversation.findOne({
        _id: req.params.id,
        isGroup: true,
        participants: userId
      });
      if (!conversation) {
        return res.status(404).json({ message: "Group not found" });
      }

      const type = req.body.type === "image" ? "image" : "text";
      const text = typeof req.body.text === "string" ? req.body.text : "";
      const imageUrl = req.file ? `/uploads/messages/${req.file.filename}` : "";

      if (type === "text" && !text.trim()) {
        return res.status(400).json({ message: "text required for text message" });
      }
      if (type === "image" && !imageUrl) {
        return res.status(400).json({ message: "image file required" });
      }

      const message = await Message.create({
        conversationId: conversation._id,
        senderId: userId,
        type,
        text: type === "text" ? text : "",
        imageUrl
      });

      const previewText = type === "text" ? text : "";
      conversation.lastMessage = {
        text: previewText,
        type,
        senderId: userId,
        createdAt: message.createdAt
      };
      conversation.lastMessageAt = message.createdAt;
      // Increment unread for all participants except the sender.
      for (const participantId of conversation.participants) {
        const pid = participantId.toString();
        if (pid === userId.toString()) continue;
        const current = conversation.unread.get(pid) ?? 0;
        conversation.unread.set(pid, current + 1);
      }
      await conversation.save();

      emitMessage(conversation.toObject(), message.toObject());

      res.status(201).json({ message, conversation });
    } catch (err) {
      next(err);
    }
  }
);

router.post("/groups/:id/read", async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({ message: "Invalid conversation id" });
    }
    const userId = req.user._id;
    const conversation = await Conversation.findOne({
      _id: req.params.id,
      isGroup: true,
      participants: userId
    });
    if (!conversation) return res.status(404).json({ message: "Group not found" });

    const readAt = new Date();
    const result = await Message.updateMany(
      {
        conversationId: conversation._id,
        senderId: { $ne: userId },
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

router.patch("/groups/:id", async (req, res, next) => {
  try {
    const { title } = req.body;
    if (typeof title !== "string" || !title.trim()) {
      return res.status(400).json({ message: "title required" });
    }
    const conv = await Conversation.findById(req.params.id);
    if (!conv || !conv.isGroup) {
      return res.status(404).json({ message: "Group not found" });
    }
    const userIdStr = req.user._id.toString();
    const isAdmin =
      conv.ownerId?.toString() === userIdStr ||
      conv.adminIds.some((id) => id.toString() === userIdStr);
    if (!isAdmin) {
      return res.status(403).json({ message: "Only admins can rename" });
    }
    conv.title = title.trim();
    await conv.save();
    const io = require("../sockets").getIo();
    for (const p of conv.participants) {
      io.to(`user:${p.toString()}`).emit("chat:group_updated", {
        conversationId: conv._id.toString(),
        title: conv.title
      });
    }
    res.json({ conversation: conv });
  } catch (err) {
    next(err);
  }
});

router.post("/groups/:id/members", async (req, res, next) => {
  try {
    const { userId: newMemberId } = req.body;
    if (!mongoose.isValidObjectId(newMemberId)) {
      return res.status(400).json({ message: "Invalid userId" });
    }
    const conv = await Conversation.findById(req.params.id);
    if (!conv || !conv.isGroup) {
      return res.status(404).json({ message: "Group not found" });
    }
    const userIdStr = req.user._id.toString();
    const isAdmin =
      conv.ownerId?.toString() === userIdStr ||
      conv.adminIds.some((id) => id.toString() === userIdStr);
    if (!isAdmin) {
      return res.status(403).json({ message: "Only admins can add members" });
    }
    if (conv.participants.some((p) => p.toString() === newMemberId)) {
      return res.status(409).json({ message: "Already a member" });
    }
    conv.participants.push(newMemberId);
    await conv.save();
    const io = require("../sockets").getIo();
    for (const p of conv.participants) {
      io.to(`user:${p.toString()}`).emit("chat:member_added", {
        conversationId: conv._id.toString(),
        userId: newMemberId
      });
    }
    res.status(201).json({ conversation: conv });
  } catch (err) {
    next(err);
  }
});

router.delete("/groups/:id/members/:userId", async (req, res, next) => {
  try {
    const conv = await Conversation.findById(req.params.id);
    if (!conv || !conv.isGroup) {
      return res.status(404).json({ message: "Group not found" });
    }
    const userIdStr = req.user._id.toString();
    const targetId = req.params.userId;
    const isOwner = conv.ownerId?.toString() === userIdStr;
    const isSelf = targetId === userIdStr;
    if (!isOwner && !isSelf) {
      return res
        .status(403)
        .json({ message: "Only owner can kick; you can leave yourself" });
    }
    if (isOwner && targetId === userIdStr) {
      return res
        .status(400)
        .json({ message: "Owner cannot leave; transfer ownership first" });
    }
    conv.participants = conv.participants.filter(
      (p) => p.toString() !== targetId
    );
    conv.adminIds = conv.adminIds.filter((p) => p.toString() !== targetId);
    await conv.save();

    const io = require("../sockets").getIo();
    const recipients = [...conv.participants.map((p) => p.toString()), targetId];
    for (const p of recipients) {
      io.to(`user:${p}`).emit("chat:member_removed", {
        conversationId: conv._id.toString(),
        userId: targetId
      });
    }
    res.json({ conversation: conv });
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
      if (!conversation) {
        return res.status(500).json({ message: "Failed to create conversation" });
      }
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
