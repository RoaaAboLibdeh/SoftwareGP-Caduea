const mongoose = require('mongoose');

const favoriteItemSchema = new mongoose.Schema({
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true
  },
  addedAt: {
    type: Date,
    default: Date.now
  }
});

const favoriteSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true // one favorites list per user
  },
  items: [favoriteItemSchema],
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

favoriteSchema.pre('save', function (next) {
  this.updatedAt = new Date();
  next();
});

const Favorite = mongoose.model('Favorite', favoriteSchema);

module.exports = Favorite;
