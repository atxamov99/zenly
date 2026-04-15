const mongoose = require("mongoose");

const geozoneVisitSchema = new mongoose.Schema(
  {
    geozone: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Geozone",
      required: true
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    isInside: {
      type: Boolean,
      default: false
    },
    enteredAt: {
      type: Date,
      default: null
    },
    exitedAt: {
      type: Date,
      default: null
    }
  },
  {
    timestamps: true
  }
);

geozoneVisitSchema.index({ geozone: 1, user: 1 }, { unique: true });

module.exports = mongoose.model("GeozoneVisit", geozoneVisitSchema);
