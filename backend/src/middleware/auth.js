const jwt = require("jsonwebtoken");

const User = require("../models/User");

async function auth(req, res, next) {
  try {
    const header = req.headers.authorization;

    if (!header || !header.startsWith("Bearer ")) {
      return res.status(401).json({ message: "Authorization token is required" });
    }

    const token = header.slice(7);
    const payload = jwt.verify(token, process.env.JWT_SECRET);

    const user = await User.findById(payload.userId).select("-passwordHash");
    if (!user) {
      return res.status(401).json({ message: "Invalid token" });
    }

    req.user = user;
    req.auth = {
      userId: payload.userId,
      sessionId: payload.sessionId || null
    };
    next();
  } catch (error) {
    next({ status: 401, message: "Unauthorized" });
  }
}

module.exports = auth;
