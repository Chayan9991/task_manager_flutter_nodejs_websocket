const express = require("express");
const Task = require("../models/Task");

const router = express.Router();

//get all task
router.get("/", async (req, res) => {
  const tasks = await Task.find();
  res.json(tasks);
});

// Create task
router.post("/", async (req, res) => {
  const task = new Task({ ...req.body, user: req.userId });
  await task.save();

  req.app.get("io").emit("task_updated", task);
  res.json(task);
});

// Update task
router.put("/:id", async (req, res) => {
  const task = await Task.findOneAndUpdate(
    { _id: req.params.id, user: req.userId },
    req.body,
    { new: true }
  );
  req.app.get("io").emit("task_updated", task);
  res.json(task);
});

// Delete task
router.delete("/:id", async (req, res) => {
  const task = await Task.findOneAndDelete({
    _id: req.params.id,
    user: req.userId,
  });
  req.app.get("io").emit("task_deleted", task._id);
  res.json({ msg: "Deleted", id: task._id });
});

module.exports = router;
