const mongoose = require('mongoose');

const BoxSelectionSchema = new mongoose.Schema({
  userId: String,
  box: String,
  boxColor: String,
  lidColor: String,
  ribbonColor: String,
  date: { type: Date, default: Date.now }
});

module.exports = mongoose.model('BoxSelection', BoxSelectionSchema);