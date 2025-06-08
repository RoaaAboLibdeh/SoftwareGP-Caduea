// models/DiscountPoints.js
const mongoose = require('mongoose');

const discountPointsSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  totalPoints: {
    type: Number,
    default: 0,
    min: 0
  },
  availablePoints: {
    type: Number,
    default: 0,
    min: 0
  },
  lifetimePointsEarned: {
    type: Number,
    default: 0,
    min: 0
  },
  lifetimePointsUsed: {
    type: Number,
    default: 0,
    min: 0
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  }
});

// Update timestamp before saving
discountPointsSchema.pre('save', function (next) {
  this.lastUpdated = new Date();
  next();
});

module.exports = mongoose.model('DiscountPoints', discountPointsSchema);