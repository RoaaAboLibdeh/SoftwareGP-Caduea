const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const productSchema = new mongoose.Schema({
  // Core Product Info
  productId: {
    type: String,
    default: uuidv4,
    unique: true
  },
  name: {
    type: String,
    required: [true, 'Product name is required'],
    trim: true
  },
  description: {
    type: String,
    required: true
  },
  owner_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  
  // Categorization
  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: true
  },
  discountAmount: {
    type: Number,
    min: 0,
    max: 100,
    default: 0
  },
  
   // e.g. 'Smartwatches' under Electronics
  
  // Pricing
  price: {
    type: Number,
    required: true
  },
  stock: {
    type: Number,
    default: 0,
    min: 0
  },
  priceRange: {
    min: Number,
    max: Number
  },
  isOnSale: {
    type: Boolean,
    default: false
  },
  
  // Gift Attributes
  recipientType: {
    type: [String],
    required: true,
    enum: [
      'Parents',
    'Friends',
    'Colleagues',
    'Wife/Husband', 
    'Grandparents',
    'Siblings',
    'child'
    ]
  },
  occasion: {
    type: [String],
    enum: [
      'Birthday',
    'Anniversary',
    'Valentine',
    'Christmas',
    'Graduation'
    ]
  },
  
  // Product Characteristics
  keywords: [String], // e.g. ['romantic', 'luxury', 'budget']
  popularity: {
    type: Number,
    default: 0,
    min: 0,
    max: 100
  },
  
  // Media
  imageUrls: [String],
  productUrl: String,
  
  // Metadata
  createdAt: {
    type: Date,
    default: Date.now
  },
  lastUpdated: Date
});

// Add to your existing Product model
productSchema.index({ recipientType: 1 });
productSchema.index({ occasion: 1 });
productSchema.index({ category: 1 });
productSchema.index({ price: 1 });

// Add text index for search
productSchema.index({
  name: 'text',
  description: 'text',
  keywords: 'text'
});

// Update timestamp before saving
productSchema.pre('save', function(next) {
  this.lastUpdated = new Date();
  next();
});

// Static method for gift recommendations
productSchema.statics.recommendGifts = async function(filters = {}) {
  const { recipient, occasion, budget, keywords } = filters;
  
  const query = {};
  
  if (recipient) query.recipientType = recipient;
  if (occasion) query.occasion = occasion;
  if (budget) query.price = { $lte: budget };
  if (keywords) query.keywords = { $in: keywords };
  
  return this.aggregate([
    { $match: query },
    { $sample: { size: 5 } }, // Get 5 random matches
    { $sort: { popularity: -1 } }
  ]);
};

const Product = mongoose.model('Product', productSchema);

module.exports = Product;