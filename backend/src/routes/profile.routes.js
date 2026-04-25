const express = require("express");
const fs = require("fs");
const path = require("path");

const auth = require("../middleware/auth");
const User = require("../models/User");
const { uploadAvatar } = require("../config/upload");

const router = express.Router();

router.use(auth);

router.patch("/", async (req, res, next) => {
  try {
    const { username, email, displayName, avatarUrl } = req.body;
    const updates = {};

    if (typeof username === "string") {
      const normalizedUsername = username.trim();

      if (!normalizedUsername || normalizedUsername.length < 3 || normalizedUsername.length > 30) {
        return res.status(400).json({ message: "username must be between 3 and 30 characters" });
      }

      const existingUser = await User.findOne({
        username: normalizedUsername,
        _id: { $ne: req.user._id }
      }).select("_id");

      if (existingUser) {
        return res.status(409).json({ message: "Username is already taken" });
      }

      updates.username = normalizedUsername;
    }

    if (typeof email === "string") {
      const normalizedEmail = email.trim().toLowerCase();

      if (!normalizedEmail || !normalizedEmail.includes("@")) {
        return res.status(400).json({ message: "A valid email is required" });
      }

      const existingUser = await User.findOne({
        email: normalizedEmail,
        _id: { $ne: req.user._id }
      }).select("_id");

      if (existingUser) {
        return res.status(409).json({ message: "Email is already taken" });
      }

      updates.email = normalizedEmail;
    }

    if (typeof displayName === "string") {
      const normalizedDisplayName = displayName.trim();

      if (!normalizedDisplayName || normalizedDisplayName.length > 60) {
        return res.status(400).json({ message: "displayName must be between 1 and 60 characters" });
      }

      updates.displayName = normalizedDisplayName;
    }

    if (avatarUrl === null || typeof avatarUrl === "string") {
      updates.avatarUrl = avatarUrl ? avatarUrl.trim() : null;
    }

    const user = await User.findByIdAndUpdate(req.user._id, updates, {
      new: true
    }).select("-passwordHash");

    res.json({
      message: "Profile updated",
      user
    });
  } catch (error) {
    next(error);
  }
});

router.post("/avatar", uploadAvatar.single("avatar"), async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: "Avatar file is required" });
    }

    const user = await User.findById(req.user._id).select("avatarUrl");

    if (user.avatarUrl && user.avatarUrl.startsWith("/uploads/avatars/")) {
      const relativeAvatarPath = user.avatarUrl.replace(/^[/\\]+/, "");
      const oldAvatarPath = path.join(__dirname, "..", "..", relativeAvatarPath);
      if (fs.existsSync(oldAvatarPath)) {
        fs.unlinkSync(oldAvatarPath);
      }
    }

    user.avatarUrl = `/uploads/avatars/${req.file.filename}`;
    await user.save();

    res.json({
      message: "Avatar uploaded",
      avatarUrl: user.avatarUrl,
      user
    });
  } catch (error) {
    next(error);
  }
});

router.patch("/privacy", async (req, res, next) => {
  try {
    const {
      locationVisibility,
      lastSeenVisibility,
      batteryVisibility,
      ghostMode
    } = req.body;
    const allowed = ["friends", "circles", "nobody"];

    if (locationVisibility && !allowed.includes(locationVisibility)) {
      return res.status(400).json({ message: "Invalid locationVisibility value" });
    }

    if (lastSeenVisibility && !allowed.includes(lastSeenVisibility)) {
      return res.status(400).json({ message: "Invalid lastSeenVisibility value" });
    }

    if (batteryVisibility && !allowed.includes(batteryVisibility)) {
      return res.status(400).json({ message: "Invalid batteryVisibility value" });
    }

    if (ghostMode !== undefined && typeof ghostMode !== "boolean") {
      return res.status(400).json({ message: "ghostMode must be boolean" });
    }

    const user = await User.findById(req.user._id);

    if (locationVisibility) {
      user.privacy.locationVisibility = locationVisibility;
    }

    if (lastSeenVisibility) {
      user.privacy.lastSeenVisibility = lastSeenVisibility;
    }

    if (batteryVisibility) {
      user.privacy.batteryVisibility = batteryVisibility;
    }

    if (typeof ghostMode === "boolean") {
      user.privacy.ghostMode = ghostMode;
    }

    await user.save();

    res.json({
      message: "Privacy settings updated",
      privacy: user.privacy
    });
  } catch (error) {
    next(error);
  }
});

// Per-friend ghost: hide my location from a specific friend.
router.put("/ghost-from/:friendId", async (req, res, next) => {
  try {
    const mongoose = require("mongoose");
    const friendId = req.params.friendId;
    if (!mongoose.isValidObjectId(friendId)) {
      return res.status(400).json({ message: "Invalid friendId" });
    }
    if (friendId === req.user._id.toString()) {
      return res.status(400).json({ message: "Cannot ghost yourself" });
    }
    const user = await User.findById(req.user._id);
    if (!user.privacy.ghostFromList.some((id) => id.toString() === friendId)) {
      user.privacy.ghostFromList.push(friendId);
      await user.save();
    }
    res.json({ ghostFromList: user.privacy.ghostFromList });
  } catch (error) {
    next(error);
  }
});

router.delete("/ghost-from/:friendId", async (req, res, next) => {
  try {
    const friendId = req.params.friendId;
    const user = await User.findById(req.user._id);
    user.privacy.ghostFromList = user.privacy.ghostFromList.filter(
      (id) => id.toString() !== friendId
    );
    await user.save();
    res.json({ ghostFromList: user.privacy.ghostFromList });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
