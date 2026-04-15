const jwt = require("jsonwebtoken");

function signAccessToken(userId, sessionId) {
  return jwt.sign({ userId, sessionId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || "7d"
  });
}

module.exports = { signAccessToken };
