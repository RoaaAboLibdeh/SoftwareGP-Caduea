const mongoose = require('mongoose');

const OrderSchema = new mongoose.Schema({
  userId: String,
  items: [{
    productId: String,
    name: String,
    price: Number,
    quantity: Number,
    imageUrl: String
  }],
  giftBox: {
    box: String,
    boxColor: String,
    lidColor: String,
    ribbonColor: String
  },
  giftCard: {
    cardImage: String,
    senderName: String,
    recipientName: String,
    message: String
  },
  deliveryDetails: {
    address: String,
    latitude: Number,
    longitude: Number
  },
  paymentMethod: String,
  totalAmount: Number,
  pointsEarned: { type: Number, default: 0 }, // Points earned from this order
  pointsUsed: { type: Number, default: 0 }, // Points redeemed in this order
  status: { type: String, default: 'pending' },
  createdAt: { type: Date, default: Date.now }
});
// Calculate points before saving
OrderSchema.pre('save', async function (next) {
  if (this.isNew) {
    // Calculate points earned (1 point for every $10 spent)
    this.pointsEarned = Math.floor(this.totalAmount / 10);
    
    // If this is the 5th order, add bonus points
    const orderCount = await mongoose.model('Order').countDocuments({ userId: this.userId });
    if (orderCount % 5 === 4) { // Because we're counting before this order is saved
      this.pointsEarned += 50; // 50 bonus points for every 5th order
    }
  }
  next();
});

// Update user's points after order is saved
OrderSchema.post('save', async function (doc) {
  try {
    const DiscountPoints = mongoose.model('DiscountPoints');
    
    // Find or create discount points record for user
    let pointsRecord = await DiscountPoints.findOne({ user: doc.userId });
    if (!pointsRecord) {
      pointsRecord = new DiscountPoints({ user: doc.userId });
    }
    
    // Update points
    pointsRecord.totalPoints += doc.pointsEarned;
    pointsRecord.availablePoints += doc.pointsEarned;
    pointsRecord.lifetimePointsEarned += doc.pointsEarned;
    pointsRecord.lifetimePointsUsed += doc.pointsUsed;
    
    await pointsRecord.save();
  } catch (err) {
    console.error('Error updating discount points:', err);
  }
});
module.exports = mongoose.model('Order', OrderSchema);