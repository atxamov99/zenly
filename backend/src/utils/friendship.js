const Friendship = require("../models/Friendship");

async function areFriends(userIdA, userIdB) {
  const friendship = await Friendship.findOne({
    status: "accepted",
    $or: [
      { requester: userIdA, recipient: userIdB },
      { requester: userIdB, recipient: userIdA }
    ]
  });

  return Boolean(friendship);
}

module.exports = { areFriends };
