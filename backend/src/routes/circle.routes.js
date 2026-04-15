const express = require("express");

const auth = require("../middleware/auth");
const Circle = require("../models/Circle");
const User = require("../models/User");
const { areFriends } = require("../utils/friendship");
const { isBlockedEitherWay } = require("../utils/blocking");

const router = express.Router();

router.use(auth);

router.get("/", async (req, res, next) => {
  try {
    const circles = await Circle.find({ owner: req.user._id })
      .populate("members", "username displayName email avatarUrl")
      .sort({ updatedAt: -1 });

    res.json({ circles });
  } catch (error) {
    next(error);
  }
});

router.post("/", async (req, res, next) => {
  try {
    const { name } = req.body;

    if (!name || typeof name !== "string") {
      return res.status(400).json({ message: "Circle name is required" });
    }

    const circle = await Circle.create({
      owner: req.user._id,
      name: name.trim()
    });

    res.status(201).json({
      message: "Circle created",
      circle
    });
  } catch (error) {
    next(error);
  }
});

router.patch("/:circleId", async (req, res, next) => {
  try {
    const circle = await Circle.findOne({
      _id: req.params.circleId,
      owner: req.user._id
    });

    if (!circle) {
      return res.status(404).json({ message: "Circle not found" });
    }

    if (typeof req.body.name === "string" && req.body.name.trim()) {
      circle.name = req.body.name.trim();
    }

    await circle.save();

    res.json({
      message: "Circle updated",
      circle
    });
  } catch (error) {
    next(error);
  }
});

router.delete("/:circleId", async (req, res, next) => {
  try {
    const circle = await Circle.findOneAndDelete({
      _id: req.params.circleId,
      owner: req.user._id
    });

    if (!circle) {
      return res.status(404).json({ message: "Circle not found" });
    }

    res.json({ message: "Circle deleted" });
  } catch (error) {
    next(error);
  }
});

router.post("/:circleId/members", async (req, res, next) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }

    const circle = await Circle.findOne({
      _id: req.params.circleId,
      owner: req.user._id
    });

    if (!circle) {
      return res.status(404).json({ message: "Circle not found" });
    }

    const user = await User.findById(userId).select("_id");
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const [friends, blocked] = await Promise.all([
      areFriends(req.user._id, userId),
      isBlockedEitherWay(req.user._id, userId)
    ]);

    if (!friends) {
      return res.status(403).json({ message: "Only accepted friends can be added to a circle" });
    }

    if (blocked) {
      return res.status(403).json({ message: "Blocked users cannot be added to a circle" });
    }

    if (!circle.members.some((memberId) => memberId.toString() === userId)) {
      circle.members.push(userId);
      await circle.save();
    }

    await circle.populate("members", "username displayName email avatarUrl");

    res.json({
      message: "Member added to circle",
      circle
    });
  } catch (error) {
    next(error);
  }
});

router.delete("/:circleId/members/:memberId", async (req, res, next) => {
  try {
    const circle = await Circle.findOne({
      _id: req.params.circleId,
      owner: req.user._id
    });

    if (!circle) {
      return res.status(404).json({ message: "Circle not found" });
    }

    circle.members = circle.members.filter(
      (memberId) => memberId.toString() !== req.params.memberId
    );
    await circle.save();
    await circle.populate("members", "username displayName email avatarUrl");

    res.json({
      message: "Member removed from circle",
      circle
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
