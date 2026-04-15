const express = require("express");

const auth = require("../middleware/auth");
const { locationUpdateLimiter } = require("../middleware/rate-limit");
const Circle = require("../models/Circle");
const Geozone = require("../models/Geozone");
const GeozoneVisit = require("../models/GeozoneVisit");
const LocationShare = require("../models/LocationShare");
const LocationHistory = require("../models/LocationHistory");
const UserLocation = require("../models/UserLocation");
const User = require("../models/User");
const { areFriends } = require("../utils/friendship");
const { isBlockedEitherWay } = require("../utils/blocking");
const { canViewerAccessByRule } = require("../utils/visibility");
const { isInsideGeozone } = require("../utils/geo");
const { createNotification } = require("../utils/notifications");
const { resolveSmartStatus } = require("../utils/smart-status");
const { getIo } = require("../sockets");

const router = express.Router();

router.use(auth);

router.post("/update", locationUpdateLimiter, async (req, res, next) => {
  try {
    const { lat, lng, accuracy } = req.body;

    if (typeof lat !== "number" || typeof lng !== "number") {
      return res.status(400).json({ message: "lat and lng must be numbers" });
    }

    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return res.status(400).json({ message: "Coordinates are out of range" });
    }

    const roundedLat = Number(lat.toFixed(6));
    const roundedLng = Number(lng.toFixed(6));
    const previousLocation = await UserLocation.findOne({ user: req.user._id });
    const locationTimestamp = new Date();

    const location = await UserLocation.findOneAndUpdate(
      { user: req.user._id },
      {
        user: req.user._id,
        lat: roundedLat,
        lng: roundedLng,
        accuracy: typeof accuracy === "number" ? accuracy : null,
        lastSeenAt: locationTimestamp
      },
      {
        upsert: true,
        new: true,
        setDefaultsOnInsert: true
      }
    );

    await LocationHistory.create({
      user: req.user._id,
      lat: roundedLat,
      lng: roundedLng,
      accuracy: typeof accuracy === "number" ? accuracy : null,
      recordedAt: location.lastSeenAt
    });

    const owner = await User.findById(req.user._id).select("privacy presence username displayName");
    const now = new Date();

    await LocationShare.updateMany(
      {
        owner: req.user._id,
        isActive: true,
        expiresAt: { $ne: null, $lte: now }
      },
      {
        isActive: false
      }
    );

    const activeShares = await LocationShare.find({
      owner: req.user._id,
      isActive: true,
      $or: [{ expiresAt: null }, { expiresAt: { $gt: now } }]
    }).select("viewer");

    const io = getIo();
    if (!owner.privacy?.ghostMode) {
      for (const share of activeShares) {
        const [friends, blocked] = await Promise.all([
          areFriends(req.user._id, share.viewer),
          isBlockedEitherWay(req.user._id, share.viewer)
        ]);

        if (blocked) {
          continue;
        }

        const canSeeLocation = await canViewerAccessByRule({
          owner,
          viewerId: share.viewer,
          rule: owner.privacy?.locationVisibility,
          areFriends: friends
        });

        if (!canSeeLocation) {
          continue;
        }

        io.to(`user:${share.viewer.toString()}`).emit("friend:location_changed", {
          friendId: req.user._id.toString(),
          lat: location.lat,
          lng: location.lng,
          accuracy: location.accuracy,
          lastSeenAt: location.lastSeenAt
        });

        if (previousSmartStatus !== nextSmartStatus) {
          io.to(`user:${share.viewer.toString()}`).emit("friend:smart_status_changed", {
            friendId: req.user._id.toString(),
            smartStatus: nextSmartStatus,
            occurredAt: locationTimestamp
          });
        }
      }
    }

    const geozones = await Geozone.find({
      owner: req.user._id,
      isActive: true
    });

    const previousSmartStatus = owner.presence?.smartStatus || "offline";
    const nextSmartStatus = resolveSmartStatus({
      isOnline: true,
      geozones,
      point: { lat: roundedLat, lng: roundedLng },
      previousLocation,
      nextLocation: location
    });

    owner.presence.smartStatus = nextSmartStatus;
    owner.presence.lastSeenAt = locationTimestamp;
    await owner.save();

    for (const geozone of geozones) {
      const inside = isInsideGeozone({ lat: roundedLat, lng: roundedLng }, geozone);
      const visit = await GeozoneVisit.findOneAndUpdate(
        {
          geozone: geozone._id,
          user: req.user._id
        },
        {},
        {
          upsert: true,
          new: true,
          setDefaultsOnInsert: true
        }
      );

      if (visit.isInside === inside) {
        continue;
      }

      visit.isInside = inside;
      if (inside) {
        visit.enteredAt = new Date();
      } else {
        visit.exitedAt = new Date();
      }
      await visit.save();

      for (const viewerId of geozone.notifyViewers) {
        const blocked = await isBlockedEitherWay(req.user._id, viewerId);
        if (blocked) {
          continue;
        }

        await createNotification({
          userId: viewerId,
          type: inside ? "geozone_entered" : "geozone_exited",
          title: inside ? "Friend entered geozone" : "Friend exited geozone",
          body: `${req.user.displayName || req.user.username} ${inside ? "entered" : "exited"} ${geozone.name}`,
          data: {
            friendId: req.user._id,
            geozoneId: geozone._id,
            event: inside ? "entered" : "exited"
          }
        });

        io.to(`user:${viewerId.toString()}`).emit("friend:geozone_event", {
          friendId: req.user._id.toString(),
          geozoneId: geozone._id.toString(),
          geozoneName: geozone.name,
          event: inside ? "entered" : "exited",
          occurredAt: new Date()
        });
      }
    }

    res.json({
      message: "Location updated",
      location
    });
  } catch (error) {
    next(error);
  }
});

router.post("/share/:friendId", async (req, res, next) => {
  try {
    const { friendId } = req.params;
    const { durationMinutes } = req.body;

    const friend = await User.findById(friendId).select("_id");
    if (!friend) {
      return res.status(404).json({ message: "Friend not found" });
    }

    const blocked = await isBlockedEitherWay(req.user._id, friend._id);
    if (blocked) {
      return res.status(403).json({ message: "Location sharing is not allowed for blocked users" });
    }

    const canShare = await areFriends(req.user._id, friend._id);
    if (!canShare) {
      return res.status(403).json({ message: "You can share location only with accepted friends" });
    }

    let expiresAt = null;
    if (durationMinutes !== undefined) {
      if (typeof durationMinutes !== "number" || durationMinutes <= 0) {
        return res.status(400).json({ message: "durationMinutes must be a positive number" });
      }

      expiresAt = new Date(Date.now() + durationMinutes * 60 * 1000);
    }

    const share = await LocationShare.findOneAndUpdate(
      {
        owner: req.user._id,
        viewer: friend._id
      },
      {
        owner: req.user._id,
        viewer: friend._id,
        isActive: true,
        expiresAt
      },
      {
        upsert: true,
        new: true,
        setDefaultsOnInsert: true
      }
    );

    res.json({
      message: "Location sharing enabled",
      share
    });
  } catch (error) {
    next(error);
  }
});

router.delete("/share/:friendId", async (req, res, next) => {
  try {
    const { friendId } = req.params;

    const share = await LocationShare.findOneAndUpdate(
      {
        owner: req.user._id,
        viewer: friendId
      },
      {
        isActive: false
      },
      { new: true }
    );

    if (!share) {
      return res.status(404).json({ message: "Share settings not found" });
    }

    res.json({
      message: "Location sharing disabled",
      share
    });
  } catch (error) {
    next(error);
  }
});

router.get("/visible-friends", async (req, res, next) => {
  try {
    const now = new Date();
    await LocationShare.updateMany(
      {
        viewer: req.user._id,
        isActive: true,
        expiresAt: { $ne: null, $lte: now }
      },
      {
        isActive: false
      }
    );

    const shares = await LocationShare.find({
      viewer: req.user._id,
      isActive: true,
      $or: [{ expiresAt: null }, { expiresAt: { $gt: now } }]
    }).select("owner");

    const ownerIds = shares.map((share) => share.owner);

    const [locations, users, circles] = await Promise.all([
      UserLocation.find({ user: { $in: ownerIds } }).sort({ lastSeenAt: -1 }),
      User.find({ _id: { $in: ownerIds } }).select("username displayName avatarUrl privacy presence"),
      Circle.find({ owner: { $in: ownerIds }, members: req.user._id }).select("owner")
    ]);

    const usersMap = new Map(users.map((user) => [user._id.toString(), user]));
    const circleOwners = new Set(circles.map((circle) => circle.owner.toString()));

    const friends = [];

    for (const location of locations) {
      const friend = usersMap.get(location.user.toString());
      if (!friend) {
        continue;
      }

      const [friendsWithOwner, blocked] = await Promise.all([
        areFriends(req.user._id, location.user),
        isBlockedEitherWay(req.user._id, location.user)
      ]);

      if (blocked) {
        continue;
      }

      const canSeeLocation = await canViewerAccessByRule({
        owner: friend,
        viewerId: req.user._id,
        rule: friend.privacy?.locationVisibility,
        areFriends: friendsWithOwner,
        inCircle: circleOwners.has(friend._id.toString())
      });

      const canSeeLastSeen = await canViewerAccessByRule({
        owner: friend,
        viewerId: req.user._id,
        rule: friend.privacy?.lastSeenVisibility,
        areFriends: friendsWithOwner,
        inCircle: circleOwners.has(friend._id.toString())
      });

      if (!canSeeLocation) {
        continue;
      }

      friends.push({
        friendId: location.user,
        username: friend.username,
        displayName: friend.displayName,
        avatarUrl: friend.avatarUrl,
        isOnline: friend.presence?.isOnline || false,
        smartStatus: friend.presence?.smartStatus || "offline",
        lat: location.lat,
        lng: location.lng,
        accuracy: location.accuracy,
        lastSeenAt: canSeeLastSeen ? location.lastSeenAt : null
      });
    }

    res.json({ friends });
  } catch (error) {
    next(error);
  }
});

router.get("/history/:friendId?", async (req, res, next) => {
  try {
    const targetUserId = req.params.friendId || req.user._id.toString();
    const limit = Math.min(Number(req.query.limit) || 50, 200);

    const owner = await User.findById(targetUserId).select("privacy");
    if (!owner) {
      return res.status(404).json({ message: "User not found" });
    }

    const [friends, blocked] = await Promise.all([
      areFriends(req.user._id, targetUserId),
      isBlockedEitherWay(req.user._id, targetUserId)
    ]);

    if (blocked) {
      return res.status(403).json({ message: "History is not available for blocked users" });
    }

    const canSeeLocation = await canViewerAccessByRule({
      owner,
      viewerId: req.user._id,
      rule: owner.privacy?.locationVisibility,
      areFriends: friends
    });

    if (!canSeeLocation) {
      return res.status(403).json({ message: "Location history is not available" });
    }

    const history = await LocationHistory.find({ user: targetUserId })
      .sort({ recordedAt: -1 })
      .limit(limit);

    res.json({ history });
  } catch (error) {
    next(error);
  }
});

router.get("/share-settings", async (req, res, next) => {
  try {
    const now = new Date();
    const shares = await LocationShare.find({ owner: req.user._id })
      .populate("viewer", "username displayName email")
      .sort({ updatedAt: -1 });

    res.json({
      shares: shares.map((share) => ({
        ...share.toObject(),
        isExpired: Boolean(share.expiresAt && share.expiresAt <= now)
      }))
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
