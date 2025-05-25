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
  status: { type: String, default: 'pending' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Order', OrderSchema);