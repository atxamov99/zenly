const fs = require("fs");
const path = require("path");
const express = require("express");
const cors = require("cors");
const swaggerUi = require("swagger-ui-express");

const authRoutes = require("./routes/auth.routes");
const profileRoutes = require("./routes/profile.routes");
const blockRoutes = require("./routes/block.routes");
const circleRoutes = require("./routes/circle.routes");
const friendRoutes = require("./routes/friend.routes");
const geozoneRoutes = require("./routes/geozone.routes");
const inviteRoutes = require("./routes/invite.routes");
const locationRoutes = require("./routes/location.routes");
const notificationRoutes = require("./routes/notification.routes");
const pushRoutes = require("./routes/push.routes");
const swaggerSpec = require("./config/swagger");

function createApp() {
  const app = express();
  const uploadsDir = path.join(__dirname, "..", "uploads");
  const avatarsDir = path.join(uploadsDir, "avatars");

  fs.mkdirSync(avatarsDir, { recursive: true });

  app.use(
    cors({
      origin: process.env.CORS_ORIGIN || "*"
    })
  );
  app.use(express.json());
  app.use("/uploads", express.static(uploadsDir));

  app.get("/health", (req, res) => {
    res.json({ ok: true });
  });

  app.use("/api/docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));
  app.get("/api/docs.json", (req, res) => {
    res.json(swaggerSpec);
  });

  app.use("/api/auth", authRoutes);
  app.use("/api/profile", profileRoutes);
  app.use("/api/blocks", blockRoutes);
  app.use("/api/circles", circleRoutes);
  app.use("/api/friends", friendRoutes);
  app.use("/api/geozones", geozoneRoutes);
  app.use("/api/invites", inviteRoutes);
  app.use("/api/location", locationRoutes);
  app.use("/api/notifications", notificationRoutes);
  app.use("/api/push", pushRoutes);

  app.use((req, res) => {
    res.status(404).json({ message: "Route not found" });
  });

  app.use((error, req, res, next) => {
    console.error(error);
    res.status(error.status || 500).json({
      message: error.message || "Internal server error"
    });
  });

  return app;
}

module.exports = createApp;
