const express = require("express");

const auth = require("../middleware/auth");
const Geozone = require("../models/Geozone");
const User = require("../models/User");
const { areFriends } = require("../utils/friendship");
const { isBlockedEitherWay } = require("../utils/blocking");

const router = express.Router();

router.use(auth);

router.get("/", async (req, res, next) => {
  try {
    const geozones = await Geozone.find({ owner: req.user._id })
      .populate("notifyViewers", "username displayName email avatarUrl")
      .sort({ updatedAt: -1 });

    res.json({ geozones });
  } catch (error) {
    next(error);
  }
});

router.post("/", async (req, res, next) => {
  try {
    const { name, kind = "custom", lat, lng, radiusMeters, notifyViewerIds = [] } = req.body;

    if (!name || typeof lat !== "number" || typeof lng !== "number" || typeof radiusMeters !== "number") {
      return res.status(400).json({ message: "name, lat, lng and radiusMeters are required" });
    }

    if (!["home", "study", "work", "custom"].includes(kind)) {
      return res.status(400).json({ message: "kind must be home, study, work or custom" });
    }

    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return res.status(400).json({ message: "Coordinates are out of range" });
    }

    const allowedViewerIds = [];

    for (const viewerId of notifyViewerIds) {
      const [friends, blocked] = await Promise.all([
        areFriends(req.user._id, viewerId),
        isBlockedEitherWay(req.user._id, viewerId)
      ]);

      if (friends && !blocked) {
        allowedViewerIds.push(viewerId);
      }
    }

    const geozone = await Geozone.create({
      owner: req.user._id,
      name: name.trim(),
      kind,
      lat,
      lng,
      radiusMeters,
      notifyViewers: allowedViewerIds
    });

    res.status(201).json({
      message: "Geozone created",
      geozone
    });
  } catch (error) {
    next(error);
  }
});

router.patch("/:geozoneId", async (req, res, next) => {
  try {
    const geozone = await Geozone.findOne({
      _id: req.params.geozoneId,
      owner: req.user._id
    });

    if (!geozone) {
      return res.status(404).json({ message: "Geozone not found" });
    }

    const { name, kind, lat, lng, radiusMeters, notifyViewerIds, isActive } = req.body;

    if (typeof name === "string" && name.trim()) {
      geozone.name = name.trim();
    }

    if (kind !== undefined) {
      if (!["home", "study", "work", "custom"].includes(kind)) {
        return res.status(400).json({ message: "kind must be home, study, work or custom" });
      }

      geozone.kind = kind;
    }

    if (typeof lat === "number") {
      geozone.lat = lat;
    }

    if (typeof lng === "number") {
      geozone.lng = lng;
    }

    if (typeof radiusMeters === "number") {
      geozone.radiusMeters = radiusMeters;
    }

    if (typeof isActive === "boolean") {
      geozone.isActive = isActive;
    }

    if (Array.isArray(notifyViewerIds)) {
      const allowedViewerIds = [];

      for (const viewerId of notifyViewerIds) {
        const [friends, blocked] = await Promise.all([
          areFriends(req.user._id, viewerId),
          isBlockedEitherWay(req.user._id, viewerId)
        ]);

        if (friends && !blocked) {
          allowedViewerIds.push(viewerId);
        }
      }

      geozone.notifyViewers = allowedViewerIds;
    }

    await geozone.save();
    await geozone.populate("notifyViewers", "username displayName email avatarUrl");

    res.json({
      message: "Geozone updated",
      geozone
    });
  } catch (error) {
    next(error);
  }
});

router.delete("/:geozoneId", async (req, res, next) => {
  try {
    const geozone = await Geozone.findOneAndDelete({
      _id: req.params.geozoneId,
      owner: req.user._id
    });

    if (!geozone) {
      return res.status(404).json({ message: "Geozone not found" });
    }

    res.json({ message: "Geozone deleted" });
  } catch (error) {
    next(error);
  }
});

router.post("/:geozoneId/viewers", async (req, res, next) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }

    const geozone = await Geozone.findOne({
      _id: req.params.geozoneId,
      owner: req.user._id
    });

    if (!geozone) {
      return res.status(404).json({ message: "Geozone not found" });
    }

    const user = await User.findById(userId).select("_id");
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const [friends, blocked] = await Promise.all([
      areFriends(req.user._id, userId),
      isBlockedEitherWay(req.user._id, userId)
    ]);

    if (!friends || blocked) {
      return res.status(403).json({ message: "Only unblocked friends can receive geozone notifications" });
    }

    if (!geozone.notifyViewers.some((viewerId) => viewerId.toString() === userId)) {
      geozone.notifyViewers.push(userId);
      await geozone.save();
    }

    await geozone.populate("notifyViewers", "username displayName email avatarUrl");

    res.json({
      message: "Viewer added to geozone",
      geozone
    });
  } catch (error) {
    next(error);
  }
});

router.delete("/:geozoneId/viewers/:viewerId", async (req, res, next) => {
  try {
    const geozone = await Geozone.findOne({
      _id: req.params.geozoneId,
      owner: req.user._id
    });

    if (!geozone) {
      return res.status(404).json({ message: "Geozone not found" });
    }

    geozone.notifyViewers = geozone.notifyViewers.filter(
      (viewerId) => viewerId.toString() !== req.params.viewerId
    );
    await geozone.save();
    await geozone.populate("notifyViewers", "username displayName email avatarUrl");

    res.json({
      message: "Viewer removed from geozone",
      geozone
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
