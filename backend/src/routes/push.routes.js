const express = require("express");

const auth = require("../middleware/auth");
const PushToken = require("../models/PushToken");

const router = express.Router();

router.use(auth);

router.get("/tokens", async (req, res, next) => {
  try {
    const tokens = await PushToken.find({ user: req.user._id }).sort({ updatedAt: -1 });
    res.json({ tokens });
  } catch (error) {
    next(error);
  }
});

router.post("/tokens", async (req, res, next) => {
  try {
    const { token, platform } = req.body;

    if (!token || !platform) {
      return res.status(400).json({ message: "token and platform are required" });
    }

    const pushToken = await PushToken.findOneAndUpdate(
      { user: req.user._id, token },
      { user: req.user._id, token, platform },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    res.status(201).json({
      message: "Push token saved",
      pushToken
    });
  } catch (error) {
    next(error);
  }
});

router.delete("/tokens/:tokenId", async (req, res, next) => {
  try {
    const deleted = await PushToken.findOneAndDelete({
      _id: req.params.tokenId,
      user: req.user._id
    });

    if (!deleted) {
      return res.status(404).json({ message: "Push token not found" });
    }

    res.json({ message: "Push token removed" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
