const mongoose = require("mongoose");

const friendInviteSchema = new mongoose.Schema(
  {
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    code: {
      type: String,
      required: true,
      unique: true,
      index: true
    },
    isActive: {
      type: Boolean,
      default: true
    },
    expiresAt: {
      type: Date,
      default: null
    },
    maxUses: {
      type: Number,
      default: 1
    },
    usedCount: {
      type: Number,
      default: 0
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model("FriendInvite", friendInviteSchema);
