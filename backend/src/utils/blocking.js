const Block = require("../models/Block");

async function findBlockingRelationship(userIdA, userIdB) {
  return Block.findOne({
    $or: [
      { blocker: userIdA, blocked: userIdB },
      { blocker: userIdB, blocked: userIdA }
    ]
  });
}

async function isBlockedEitherWay(userIdA, userIdB) {
  const block = await findBlockingRelationship(userIdA, userIdB);
  return Boolean(block);
}

module.exports = {
  findBlockingRelationship,
  isBlockedEitherWay
};
