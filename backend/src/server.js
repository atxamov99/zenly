require("dotenv").config();

const http = require("http");

const createApp = require("./app");
const connectToDatabase = require("./config/db");
const initSocket = require("./sockets");

const PORT = process.env.PORT || 4000;

async function bootstrap() {
  await connectToDatabase();

  const app = createApp();
  const server = http.createServer(app);

  initSocket(server);

  server.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
  });
}

bootstrap().catch((error) => {
  console.error("Failed to start server", error);
  process.exit(1);
});
