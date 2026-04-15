const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      minlength: 3,
      maxlength: 30
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true
    },
    passwordHash: {
      type: String,
      required: true
    },
    displayName: {
      type: String,
      trim: true,
      maxlength: 60
    },
    avatarUrl: {
      type: String,
      trim: true,
      default: null
    },
    presence: {
      isOnline: {
        type: Boolean,
        default: false
      },
      lastSeenAt: {
        type: Date,
        default: null
      },
      smartStatus: {
        type: String,
        enum: ["offline", "home", "study", "work", "on_the_way", "idle", "custom_place"],
        default: "offline"
      }
    },
    privacy: {
      locationVisibility: {
        type: String,
        enum: ["friends", "circles", "nobody"],
        default: "friends"
      },
      lastSeenVisibility: {
        type: String,
        enum: ["friends", "circles", "nobody"],
        default: "friends"
      },
      ghostMode: {
        type: Boolean,
        default: false
      }
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model("User", userSchema);
