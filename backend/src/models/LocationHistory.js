const mongoose = require("mongoose");

const locationHistorySchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    lat: {
      type: Number,
      required: true
    },
    lng: {
      type: Number,
      required: true
    },
    accuracy: {
      type: Number,
      default: null
    },
    recordedAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: true
  }
);

locationHistorySchema.index({ user: 1, recordedAt: -1 });

module.exports = mongoose.model("LocationHistory", locationHistorySchema);
