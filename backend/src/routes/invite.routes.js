const express = require("express");

const auth = require("../middleware/auth");
const FriendInvite = require("../models/FriendInvite");
const Friendship = require("../models/Friendship");
const User = require("../models/User");
const { generateInviteCode } = require("../utils/code");
const { isBlockedEitherWay } = require("../utils/blocking");
const { createNotification } = require("../utils/notifications");

const router = express.Router();

router.use(auth);

router.get("/", async (req, res, next) => {
  try {
    const invites = await FriendInvite.find({ owner: req.user._id }).sort({ createdAt: -1 });
    res.json({ invites });
  } catch (error) {
    next(error);
  }
});

router.post("/", async (req, res, next) => {
  try {
    const { expiresInHours, maxUses } = req.body;

    let expiresAt = null;
    if (expiresInHours !== undefined) {
      if (typeof expiresInHours !== "number" || expiresInHours <= 0) {
        return res.status(400).json({ message: "expiresInHours must be a positive number" });
      }
      expiresAt = new Date(Date.now() + expiresInHours * 60 * 60 * 1000);
    }

    const invite = await FriendInvite.create({
      owner: req.user._id,
      code: generateInviteCode(),
      expiresAt,
      maxUses: typeof maxUses === "number" && maxUses > 0 ? Math.floor(maxUses) : 1
    });

    res.status(201).json({
      message: "Invite created",
      invite
    });
  } catch (error) {
    next(error);
  }
});

router.post("/use/:code", async (req, res, next) => {
  try {
    const invite = await FriendInvite.findOne({
      code: req.params.code,
      isActive: true
    });

    if (!invite) {
      return res.status(404).json({ message: "Invite not found" });
    }

    if (invite.owner.toString() === req.user._id.toString()) {
      return res.status(400).json({ message: "You cannot use your own invite" });
    }

    if (invite.expiresAt && invite.expiresAt <= new Date()) {
      invite.isActive = false;
      await invite.save();
      return res.status(410).json({ message: "Invite expired" });
    }

    if (invite.usedCount >= invite.maxUses) {
      invite.isActive = false;
      await invite.save();
      return res.status(410).json({ message: "Invite usage limit reached" });
    }

    const blocked = await isBlockedEitherWay(req.user._id, invite.owner);
    if (blocked) {
      return res.status(403).json({ message: "Invite cannot be used because one of the users is blocked" });
    }

    const existing = await Friendship.findOne({
      $or: [
        { requester: req.user._id, recipient: invite.owner },
        { requester: invite.owner, recipient: req.user._id }
      ]
    });

    if (existing) {
      return res.status(409).json({ message: `Friend relationship already exists with status ${existing.status}` });
    }

    const friendship = await Friendship.create({
      requester: req.user._id,
      recipient: invite.owner
    });

    invite.usedCount += 1;
    if (invite.usedCount >= invite.maxUses) {
      invite.isActive = false;
    }
    await invite.save();

    const requester = await User.findById(req.user._id).select("username displayName");

    await Promise.all([
      createNotification({
        userId: invite.owner,
        type: "invite_used",
        title: "Invite used",
        body: `${requester.displayName || requester.username} used your invite link`,
        data: {
          inviteId: invite._id,
          requesterId: req.user._id,
          friendshipId: friendship._id
        }
      }),
      createNotification({
        userId: invite.owner,
        type: "friend_request_received",
        title: "New friend request",
        body: `${requester.displayName || requester.username} sent you a friend request`,
        data: {
          friendshipId: friendship._id,
          requesterId: req.user._id
        }
      })
    ]);

    res.status(201).json({
      message: "Invite used successfully",
      friendship
    });
  } catch (error) {
    next(error);
  }
});

router.delete("/:inviteId", async (req, res, next) => {
  try {
    const invite = await FriendInvite.findOneAndUpdate(
      {
        _id: req.params.inviteId,
        owner: req.user._id
      },
      {
        isActive: false
      },
      { new: true }
    );

    if (!invite) {
      return res.status(404).json({ message: "Invite not found" });
    }

    res.json({
      message: "Invite deactivated",
      invite
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
