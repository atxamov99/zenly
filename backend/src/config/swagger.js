const swaggerJsdoc = require("swagger-jsdoc");

const spec = swaggerJsdoc({
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Blink Clone Backend API",
      version: "1.0.0",
      description: "Educational backend API for friend location sharing."
    },
    servers: [
      {
        url: "http://localhost:4000"
      }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT"
        }
      }
    }
  },
  apis: []
});

module.exports = spec;
