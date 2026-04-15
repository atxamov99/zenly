function isEmail(value) {
  return typeof value === "string" && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.trim());
}

function isStrongEnoughPassword(value) {
  return typeof value === "string" && value.length >= 8;
}

function isUsername(value) {
  return typeof value === "string" && /^[a-zA-Z0-9_]{3,30}$/.test(value.trim());
}

module.exports = {
  isEmail,
  isStrongEnoughPassword,
  isUsername
};
