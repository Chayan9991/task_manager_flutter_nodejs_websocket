const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require("http");
const { Server } = require("socket.io");
require("dotenv").config();

const authRoutes = require("./routes/auth");
const taskRoutes = require("./routes/tasks");
const { verifyJWT } = require("./middleware/auth");
const userRoutes = require("./routes/user");

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*" },
});

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use("/api", authRoutes);
app.use("/api/tasks", verifyJWT, taskRoutes);
app.use("/api/user", verifyJWT, userRoutes);

// WebSocket
io.on("connection", (socket) => {
  console.log("Client connected:", socket.id);
  socket.on("disconnect", () => {
    console.log("Client disconnected:", socket.id);
  });
});

// Global broadcast function
app.set("io", io);

mongoose
  .connect(process.env.MONGO_URI, {
    tlsAllowInvalidCertificates: true,
    //tlsInsecure: true,
  })
  .then(() => {
    console.log("MongoDB Connected");

    const PORT = process.env.PORT || 3000;
    server.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error("Failed to connect to MongoDB", err);
    process.exit(1);
  });
