const path = require("path");
const fs = require("fs");

const multer = require("multer");

const avatarsDir = path.join(__dirname, "..", "..", "uploads", "avatars");

fs.mkdirSync(avatarsDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, avatarsDir);
  },
  filename: (req, file, cb) => {
    const safeExt = path.extname(file.originalname || "").toLowerCase() || ".jpg";
    const uniqueName = `${req.user._id.toString()}-${Date.now()}${safeExt}`;
    cb(null, uniqueName);
  }
});

function fileFilter(req, file, cb) {
  if (!file.mimetype || !file.mimetype.startsWith("image/")) {
    return cb(new Error("Only image files are allowed"));
  }

  cb(null, true);
}

const uploadAvatar = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024
  }
});

module.exports = {
  uploadAvatar
};
