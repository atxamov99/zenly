const express = require("express");

const Friendship = require("../models/Friendship");
const LocationShare = require("../models/LocationShare");
const User = require("../models/User");
const auth = require("../middleware/auth");
const { isBlockedEitherWay } = require("../utils/blocking");
const { canViewerAccessByRule } = require("../utils/visibility");
const { areFriends } = require("../utils/friendship");
const { createNotification } = require("../utils/notifications");

const router = express.Router();

router.use(auth);

router.get("/search", async (req, res, next) => {
  try {
    const q = (req.query.q || "").trim();

    if (!q) {
      return res.json({ users: [] });
    }

    const users = await User.find({
      _id: { $ne: req.user._id },
      username: { $regex: q, $options: "i" }
    })
      .select("username displayName email avatarUrl presence privacy")
      .limit(20);

    const visibleUsers = [];

    for (const user of users) {
      const [friends, blocked] = await Promise.all([
        areFriends(req.user._id, user._id),
        isBlockedEitherWay(req.user._id, user._id)
      ]);

      if (blocked) {
        continue;
      }

      const canSeeLastSeen = await canViewerAccessByRule({
        owner: user,
        viewerId: req.user._id,
        rule: user.privacy?.lastSeenVisibility,
        areFriends: friends
      });

      visibleUsers.push({
        id: user._id,
        username: user.username,
        displayName: user.displayName,
        email: user.email,
        avatarUrl: user.avatarUrl,
        presence: {
          isOnline: user.presence?.isOnline || false,
          lastSeenAt: canSeeLastSeen ? user.presence?.lastSeenAt || null : null,
          smartStatus: user.presence?.smartStatus || "offline"
        }
      });
    }

    res.json({ users: visibleUsers });
  } catch (error) {
    next(error);
  }
});

router.get("/", async (req, res, next) => {
  try {
    const friendships = await Friendship.find({
      status: "accepted",
      $or: [{ requester: req.user._id }, { recipient: req.user._id }]
    })
      .populate("requester", "username displayName email avatarUrl presence privacy")
      .populate("recipient", "username displayName email avatarUrl presence privacy")
      .sort({ updatedAt: -1 });

    const friends = friendships.map((friendship) => {
      const friend =
        friendship.requester._id.toString() === req.user._id.toString()
          ? friendship.recipient
          : friendship.requester;

      const canSeeLastSeen = ["friends", "circles"].includes(
        friend.privacy?.lastSeenVisibility || "friends"
      );

      return {
        friendshipId: friendship._id,
        id: friend._id,
        username: friend.username,
        displayName: friend.displayName,
        email: friend.email,
        avatarUrl: friend.avatarUrl,
        presence: {
          isOnline: friend.presence?.isOnline || false,
          lastSeenAt: canSeeLastSeen ? friend.presence?.lastSeenAt || null : null,
          smartStatus: friend.presence?.smartStatus || "offline"
        }
      };
    });

    res.json({ friends });
  } catch (error) {
    next(error);
  }
});

router.get("/requests", async (req, res, next) => {
  try {
    const incoming = await Friendship.find({
      recipient: req.user._id,
      status: "pending"
    }).populate("requester", "username displayName email");

    const outgoing = await Friendship.find({
      requester: req.user._id,
      status: "pending"
    }).populate("recipient", "username displayName email");

    res.json({
      incoming,
      outgoing
    });
  } catch (error) {
    next(error);
  }
});

router.post("/request", async (req, res, next) => {
  try {
    const { username } = req.body;

    if (!username) {
      return res.status(400).json({ message: "username is required" });
    }

    const recipient = await User.findOne({ username });
    if (!recipient) {
      return res.status(404).json({ message: "User not found" });
    }

    if (recipient._id.toString() === req.user._id.toString()) {
      return res.status(400).json({ message: "You cannot add yourself" });
    }

    const blocked = await isBlockedEitherWay(req.user._id, recipient._id);
    if (blocked) {
      return res.status(403).json({ message: "Friend request is not allowed for blocked users" });
    }

    const [direct, reverse] = await Promise.all([
      Friendship.findOne({ requester: req.user._id, recipient: recipient._id }),
      Friendship.findOne({ requester: recipient._id, recipient: req.user._id })
    ]);

    const existing = direct || reverse;
    if (existing) {
      return res.status(409).json({ message: `Friend request already exists with status ${existing.status}` });
    }

    const friendship = await Friendship.create({
      requester: req.user._id,
      recipient: recipient._id
    });

    await createNotification({
      userId: recipient._id,
      type: "friend_request_received",
      title: "New friend request",
      body: `${req.user.displayName || req.user.username} sent you a friend request`,
      data: {
        friendshipId: friendship._id,
        requesterId: req.user._id
      }
    });

    res.status(201).json({
      message: "Friend request sent",
      friendship
    });
  } catch (error) {
    next(error);
  }
});

router.patch("/:requestId/respond", async (req, res, next) => {
  try {
    const { requestId } = req.params;
    const { action } = req.body;

    if (!["accepted", "declined"].includes(action)) {
      return res.status(400).json({ message: "action must be accepted or declined" });
    }

    const friendship = await Friendship.findOne({
      _id: requestId,
      recipient: req.user._id,
      status: "pending"
    });

    if (!friendship) {
      return res.status(404).json({ message: "Friend request not found" });
    }

    friendship.status = action;
    await friendship.save();

    if (action === "accepted") {
      await createNotification({
        userId: friendship.requester,
        type: "friend_request_accepted",
        title: "Friend request accepted",
        body: `${req.user.displayName || req.user.username} accepted your friend request`,
        data: {
          friendshipId: friendship._id,
          accepterId: req.user._id
        }
      });
    }

    res.json({
      message: `Friend request ${action}`,
      friendship
    });
  } catch (error) {
    next(error);
  }
});

router.delete("/request/:requestId", async (req, res, next) => {
  try {
    const friendship = await Friendship.findOneAndDelete({
      _id: req.params.requestId,
      requester: req.user._id,
      status: "pending"
    });

    if (!friendship) {
      return res.status(404).json({ message: "Outgoing friend request not found" });
    }

    res.json({
      message: "Outgoing friend request canceled"
    });
  } catch (error) {
    next(error);
  }
});

router.delete("/:friendId", async (req, res, next) => {
  try {
    const { friendId } = req.params;

    const friendship = await Friendship.findOneAndDelete({
      status: "accepted",
      $or: [
        { requester: req.user._id, recipient: friendId },
        { requester: friendId, recipient: req.user._id }
      ]
    });

    if (!friendship) {
      return res.status(404).json({ message: "Friendship not found" });
    }

    await LocationShare.deleteMany({
      $or: [
        { owner: req.user._id, viewer: friendId },
        { owner: friendId, viewer: req.user._id }
      ]
    });

    await createNotification({
      userId: friendId,
      type: "friend_removed",
      title: "Friend removed",
      body: `${req.user.displayName || req.user.username} removed you from friends`,
      data: {
        removedBy: req.user._id
      }
    });

    res.json({
      message: "Friend removed"
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
