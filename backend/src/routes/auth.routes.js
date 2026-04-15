const express = require("express");
const bcrypt = require("bcryptjs");

const User = require("../models/User");
const Session = require("../models/Session");
const PasswordResetToken = require("../models/PasswordResetToken");
const auth = require("../middleware/auth");
const { authLimiter } = require("../middleware/rate-limit");
const { createSession, getRefreshExpiryDate } = require("../utils/session");
const { signAccessToken } = require("../utils/jwt");
const { generateOpaqueToken, sha256 } = require("../utils/tokens");
const { isEmail, isStrongEnoughPassword, isUsername } = require("../utils/validation");

const router = express.Router();

function serializeUser(user) {
  return {
    id: user._id,
    username: user.username,
    email: user.email,
    displayName: user.displayName,
    avatarUrl: user.avatarUrl,
    privacy: user.privacy,
    presence: user.presence
  };
}

router.post("/register", authLimiter, async (req, res, next) => {
  try {
    const { username, email, password, displayName } = req.body;

    if (!isUsername(username) || !isEmail(email) || !isStrongEnoughPassword(password)) {
      return res.status(400).json({
        message: "username, email or password is invalid"
      });
    }

    const normalizedUsername = username.trim();
    const normalizedEmail = email.trim().toLowerCase();

    const existingUser = await User.findOne({
      $or: [{ email: normalizedEmail }, { username: normalizedUsername }]
    });

    if (existingUser) {
      return res.status(409).json({ message: "User with this email or username already exists" });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const user = await User.create({
      username: normalizedUsername,
      email: normalizedEmail,
      passwordHash,
      displayName: displayName || normalizedUsername
    });

    const { accessToken, refreshToken, session } = await createSession(user, req);

    res.status(201).json({
      accessToken,
      refreshToken,
      sessionId: session._id,
      user: serializeUser(user)
    });
  } catch (error) {
    next(error);
  }
});

router.post("/login", authLimiter, async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!isEmail(email) || typeof password !== "string") {
      return res.status(400).json({ message: "email and password are required" });
    }

    const user = await User.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const isValid = await bcrypt.compare(password, user.passwordHash);
    if (!isValid) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const { accessToken, refreshToken, session } = await createSession(user, req);

    res.json({
      accessToken,
      refreshToken,
      sessionId: session._id,
      user: serializeUser(user)
    });
  } catch (error) {
    next(error);
  }
});

router.post("/refresh", authLimiter, async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (typeof refreshToken !== "string" || !refreshToken) {
      return res.status(400).json({ message: "refreshToken is required" });
    }

    const session = await Session.findOne({
      refreshTokenHash: sha256(refreshToken)
    }).populate("user");

    if (!session || session.expiresAt <= new Date()) {
      if (session) {
        await Session.deleteOne({ _id: session._id });
      }
      return res.status(401).json({ message: "Invalid refresh token" });
    }

    const newRefreshToken = generateOpaqueToken();
    session.refreshTokenHash = sha256(newRefreshToken);
    session.lastUsedAt = new Date();
    session.expiresAt = getRefreshExpiryDate();
    await session.save();

    const accessToken = signAccessToken(session.user._id.toString(), session._id.toString());

    res.json({
      accessToken,
      refreshToken: newRefreshToken,
      sessionId: session._id,
      user: serializeUser(session.user)
    });
  } catch (error) {
    next(error);
  }
});

router.get("/me", auth, async (req, res) => {
  res.json({ user: req.user });
});

router.get("/sessions", auth, async (req, res, next) => {
  try {
    const sessions = await Session.find({
      user: req.user._id,
      expiresAt: { $gt: new Date() }
    }).sort({ lastUsedAt: -1 });

    res.json({
      sessions: sessions.map((session) => ({
        id: session._id,
        userAgent: session.userAgent,
        ipAddress: session.ipAddress,
        lastUsedAt: session.lastUsedAt,
        expiresAt: session.expiresAt,
        isCurrent: req.auth.sessionId === session._id.toString()
      }))
    });
  } catch (error) {
    next(error);
  }
});

router.post("/change-password", auth, async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (typeof currentPassword !== "string" || !isStrongEnoughPassword(newPassword)) {
      return res.status(400).json({ message: "currentPassword and valid newPassword are required" });
    }

    const user = await User.findById(req.user._id);
    const isValid = await bcrypt.compare(currentPassword, user.passwordHash);

    if (!isValid) {
      return res.status(401).json({ message: "Current password is incorrect" });
    }

    user.passwordHash = await bcrypt.hash(newPassword, 10);
    await user.save();

    await Session.deleteMany({
      user: req.user._id,
      _id: { $ne: req.auth.sessionId }
    });

    res.json({ message: "Password changed" });
  } catch (error) {
    next(error);
  }
});

router.post("/forgot-password", authLimiter, async (req, res, next) => {
  try {
    const { email } = req.body;

    if (!isEmail(email)) {
      return res.status(400).json({ message: "Valid email is required" });
    }

    const user = await User.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      return res.json({
        message: "If the account exists, a reset token has been created"
      });
    }

    await PasswordResetToken.deleteMany({ user: user._id, usedAt: null });

    const rawToken = generateOpaqueToken();
    const resetToken = await PasswordResetToken.create({
      user: user._id,
      tokenHash: sha256(rawToken),
      expiresAt: new Date(Date.now() + 60 * 60 * 1000)
    });

    res.json({
      message: "Password reset token created",
      resetToken: rawToken,
      expiresAt: resetToken.expiresAt
    });
  } catch (error) {
    next(error);
  }
});

router.post("/reset-password", authLimiter, async (req, res, next) => {
  try {
    const { token, newPassword } = req.body;

    if (typeof token !== "string" || !isStrongEnoughPassword(newPassword)) {
      return res.status(400).json({ message: "token and valid newPassword are required" });
    }

    const resetRecord = await PasswordResetToken.findOne({
      tokenHash: sha256(token),
      usedAt: null,
      expiresAt: { $gt: new Date() }
    });

    if (!resetRecord) {
      return res.status(400).json({ message: "Reset token is invalid or expired" });
    }

    const user = await User.findById(resetRecord.user);
    user.passwordHash = await bcrypt.hash(newPassword, 10);
    await user.save();

    resetRecord.usedAt = new Date();
    await resetRecord.save();

    await Session.deleteMany({ user: user._id });

    res.json({ message: "Password reset successful" });
  } catch (error) {
    next(error);
  }
});

router.post("/logout", auth, async (req, res, next) => {
  try {
    if (req.auth.sessionId) {
      await Session.deleteOne({
        _id: req.auth.sessionId,
        user: req.user._id
      });
    }

    res.json({ message: "Logged out" });
  } catch (error) {
    next(error);
  }
});

router.post("/logout-all", auth, async (req, res, next) => {
  try {
    await Session.deleteMany({ user: req.user._id });
    res.json({ message: "Logged out from all devices" });
  } catch (error) {
    next(error);
  }
});

router.delete("/sessions/:sessionId", auth, async (req, res, next) => {
  try {
    const session = await Session.findOneAndDelete({
      _id: req.params.sessionId,
      user: req.user._id
    });

    if (!session) {
      return res.status(404).json({ message: "Session not found" });
    }

    res.json({ message: "Session revoked" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
