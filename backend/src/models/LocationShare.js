const mongoose = require("mongoose");

const locationShareSchema = new mongoose.Schema(
  {
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    viewer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    isActive: {
      type: Boolean,
      default: true
    },
    expiresAt: {
      type: Date,
      default: null
    }
  },
  {
    timestamps: true
  }
);

locationShareSchema.index({ owner: 1, viewer: 1 }, { unique: true });

module.exports = mongoose.model("LocationShare", locationShareSchema);
