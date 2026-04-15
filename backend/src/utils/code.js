const crypto = require("crypto");

function generateInviteCode() {
  return crypto.randomBytes(12).toString("hex");
}

module.exports = {
  generateInviteCode
};
