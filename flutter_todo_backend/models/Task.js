const mongoose = require("mongoose");

const TaskSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: String,
  category: String,
  priority: { type: String, enum: ['High', 'Medium', 'Low'], default: 'Low' },
  isCompleted: { type: Boolean, default: false },
  dueDate: Date,
}, { timestamps: true });

module.exports = mongoose.model("Task", TaskSchema);
