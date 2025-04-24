const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  avatarId: { type: String, required: true },
  text: { type: String, required: true },
  isAvatar: { type: Boolean, required: true },
  timestamp: { type: Date, default: Date.now },
  metadata: {
    intent: String,
    entities: [{
      entity: String,
      value: String,
      confidence: Number
    }]
  }
});

messageSchema.index({ userId: 1, avatarId: 1, timestamp: -1 });

module.exports = mongoose.model('Message', messageSchema);