const Session = require("../models/Session");
const { signAccessToken } = require("./jwt");
const { generateOpaqueToken, sha256 } = require("./tokens");

function getRefreshExpiryDate() {
  const days = Number(process.env.REFRESH_TOKEN_DAYS) || 30;
  return new Date(Date.now() + days * 24 * 60 * 60 * 1000);
}

async function createSession(user, req) {
  const rawRefreshToken = generateOpaqueToken();
  const session = await Session.create({
    user: user._id,
    refreshTokenHash: sha256(rawRefreshToken),
    userAgent: req.get("user-agent") || null,
    ipAddress: req.ip || req.socket?.remoteAddress || null,
    lastUsedAt: new Date(),
    expiresAt: getRefreshExpiryDate()
  });

  const accessToken = signAccessToken(user._id.toString(), session._id.toString());

  return {
    accessToken,
    refreshToken: rawRefreshToken,
    session
  };
}

module.exports = {
  createSession,
  getRefreshExpiryDate
};
