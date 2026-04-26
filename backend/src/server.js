require("dotenv").config();

const http = require("http");

const createApp = require("./app");
const connectToDatabase = require("./config/db");
const initSocket = require("./sockets");

const PORT = process.env.PORT || 4000;

async function bootstrap() {
  console.log("Connecting to MongoDB...");
  await connectToDatabase();
  console.log("MongoDB connected. Creating app...");

  const app = createApp();
  const server = http.createServer(app);

  initSocket(server);

  server.listen(PORT, "0.0.0.0", () => {
    console.log(`Server listening on port ${PORT}`);
  });
}

bootstrap().catch((error) => {
  process.stdout.write("=== STARTUP ERROR ===\n");
  process.stdout.write(String(error.message) + "\n");
  process.stdout.write(String(error.stack) + "\n");
  setTimeout(() => process.exit(1), 500);
});
