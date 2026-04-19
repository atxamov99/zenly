const path = require("path");
const fs = require("fs");

const multer = require("multer");

const uploadsRoot = path.join(__dirname, "..", "..", "uploads");
const avatarsDir = path.join(uploadsRoot, "avatars");
const messagesDir = path.join(uploadsRoot, "messages");

fs.mkdirSync(avatarsDir, { recursive: true });
fs.mkdirSync(messagesDir, { recursive: true });

function makeStorage(dir) {
  return multer.diskStorage({
    destination: (req, file, cb) => cb(null, dir),
    filename: (req, file, cb) => {
      const safeExt = path.extname(file.originalname || "").toLowerCase() || ".jpg";
      const uniqueName = `${req.user._id.toString()}-${Date.now()}${safeExt}`;
      cb(null, uniqueName);
    }
  });
}

function imageFilter(req, file, cb) {
  if (!file.mimetype || !file.mimetype.startsWith("image/")) {
    return cb(new Error("Only image files are allowed"));
  }
  cb(null, true);
}

const uploadAvatar = multer({
  storage: makeStorage(avatarsDir),
  fileFilter: imageFilter,
  limits: { fileSize: 5 * 1024 * 1024 }
});

const uploadMessageImage = multer({
  storage: makeStorage(messagesDir),
  fileFilter: imageFilter,
  limits: { fileSize: 10 * 1024 * 1024 } // 10 MB matches spec edge-case
});

module.exports = {
  uploadAvatar,
  uploadMessageImage
};
