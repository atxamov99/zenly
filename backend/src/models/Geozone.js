const mongoose = require("mongoose");

const geozoneSchema = new mongoose.Schema(
  {
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    name: {
      type: String,
      required: true,
      trim: true,
      maxlength: 60
    },
    kind: {
      type: String,
      enum: ["home", "study", "work", "custom"],
      default: "custom"
    },
    lat: {
      type: Number,
      required: true
    },
    lng: {
      type: Number,
      required: true
    },
    radiusMeters: {
      type: Number,
      required: true,
      min: 20,
      max: 5000
    },
    notifyViewers: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
      }
    ],
    isActive: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

geozoneSchema.index({ owner: 1, isActive: 1 });

module.exports = mongoose.model("Geozone", geozoneSchema);
