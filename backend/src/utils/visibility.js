const Circle = require("../models/Circle");

function normalizeVisibilityRule(rule) {
  return ["friends", "circles", "nobody"].includes(rule) ? rule : "nobody";
}

async function canViewerAccessByRule({ owner, viewerId, rule, areFriends, inCircle }) {
  const normalized = normalizeVisibilityRule(rule);

  if (!viewerId) {
    return false;
  }

  if (owner._id.toString() === viewerId.toString()) {
    return true;
  }

  if (normalized === "nobody") {
    return false;
  }

  if (normalized === "friends") {
    return areFriends;
  }

  if (!areFriends) {
    return false;
  }

  if (typeof inCircle === "boolean") {
    return inCircle;
  }

  const circle = await Circle.findOne({
    owner: owner._id,
    members: viewerId
  }).select("_id");

  return Boolean(circle);
}

module.exports = {
  canViewerAccessByRule,
  normalizeVisibilityRule
};
