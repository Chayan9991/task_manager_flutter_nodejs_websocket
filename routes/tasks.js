const express = require("express");
const Task = require("../models/Task");

const router = express.Router();

//get all task
router.get("/", async (req, res) => {
  try {
    const tasks = await Task.find().populate("user", "name");
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch tasks" });
  }
});

// Create task
router.post("/", async (req, res) => {
  try {
    const task = new Task({ ...req.body, user: req.userId });
    await task.save();

    // Populate the user field *before* emitting
    const populatedTask = await Task.findById(task._id).populate(
      "user",
      "name"
    );

    req.app.get("io").emit("task_updated", populatedTask); // Emit the populated task
    res.json(populatedTask); // Also send the populated task in the HTTP response
  } catch (err) {
    console.error("Error creating task:", err);
    res.status(500).json({ error: "Failed to create task" });
  }
});

// Update task
router.put("/:id", async (req, res) => {
  try {
    const task = await Task.findOneAndUpdate(
      { _id: req.params.id, user: req.userId },
      req.body,
      { new: true } // Returns the updated document
    );

    if (!task) {
      return res.status(404).json({ error: "Task not found or unauthorized" });
    }

    // Populate the user field *before* emitting
    const populatedTask = await Task.findById(task._id).populate(
      "user",
      "name"
    );

    req.app.get("io").emit("task_updated", populatedTask); // Emit the populated task
    res.json(populatedTask); // Also send the populated task in the HTTP response
  } catch (err) {
    console.error("Error updating task:", err);
    res.status(500).json({ error: "Failed to update task" });
  }
});

// Delete task
router.delete("/:id", async (req, res) => {
  try {
    const task = await Task.findOneAndDelete({
      _id: req.params.id,
      user: req.userId,
    });

    if (!task) {
      return res.status(404).json({ error: "Task not found or unauthorized" });
    }

    req.app.get("io").emit("task_deleted", task._id);
    res.json({ msg: "Deleted", id: task._id });
  } catch (err) {
    console.error("Error deleting task:", err);
    res.status(500).json({ error: "Failed to delete task" });
  }
});

module.exports = router;
