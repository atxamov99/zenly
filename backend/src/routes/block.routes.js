const express = require("express");

const auth = require("../middleware/auth");
const Block = require("../models/Block");
const Friendship = require("../models/Friendship");
const LocationShare = require("../models/LocationShare");
const User = require("../models/User");
const { findBlockingRelationship } = require("../utils/blocking");
const { createNotification } = require("../utils/notifications");

const router = express.Router();

router.use(auth);

router.get("/", async (req, res, next) => {
  try {
    const blocks = await Block.find({ blocker: req.user._id })
      .populate("blocked", "username displayName email avatarUrl")
      .sort({ createdAt: -1 });

    res.json({ blocks });
  } catch (error) {
    next(error);
  }
});

router.post("/:userId", async (req, res, next) => {
  try {
    const { userId } = req.params;

    if (userId === req.user._id.toString()) {
      return res.status(400).json({ message: "You cannot block yourself" });
    }

    const existing = await findBlockingRelationship(req.user._id, userId);
    if (existing && existing.blocker.toString() === req.user._id.toString()) {
      return res.status(409).json({ message: "User is already blocked" });
    }

    const block = await Block.findOneAndUpdate(
      { blocker: req.user._id, blocked: userId },
      { blocker: req.user._id, blocked: userId },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    await Promise.all([
      Friendship.deleteMany({
        $or: [
          { requester: req.user._id, recipient: userId },
          { requester: userId, recipient: req.user._id }
        ]
      }),
      LocationShare.deleteMany({
        $or: [
          { owner: req.user._id, viewer: userId },
          { owner: userId, viewer: req.user._id }
        ]
      })
    ]);

    const blocker = await User.findById(req.user._id).select("username displayName");
    await createNotification({
      userId,
      type: "user_blocked",
      title: "You were blocked",
      body: `${blocker.displayName || blocker.username} blocked you`,
      data: {
        blockerId: req.user._id
      }
    });

    res.status(201).json({
      message: "User blocked",
      block
    });
  } catch (error) {
    next(error);
  }
});

router.delete("/:userId", async (req, res, next) => {
  try {
    const deleted = await Block.findOneAndDelete({
      blocker: req.user._id,
      blocked: req.params.userId
    });

    if (!deleted) {
      return res.status(404).json({ message: "Blocked user not found" });
    }

    res.json({ message: "User unblocked" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
