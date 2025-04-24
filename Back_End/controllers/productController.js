const Product = require('../models/Product');
const asyncHandler = require('express-async-handler');
const mongoose = require('mongoose');

// @desc    Get all products (with filtering)
// @route   GET /api/products
// @access  Public
exports.getProducts = asyncHandler(async (req, res) => {
  try {
    // Extract query parameters
    const { category, recipient, occasion, minPrice, maxPrice, keyword, limit = 20 } = req.query;
    
    // Build filter object
    const filter = {};
    
    if (category) filter.category = category;
    if (recipient) filter.recipientType = recipient;
    if (occasion) filter.occasion = occasion;
    if (minPrice || maxPrice) {
      filter.price = {};
      if (minPrice) filter.price.$gte = Number(minPrice);
      if (maxPrice) filter.price.$lte = Number(maxPrice);
    }
    if (keyword) {
      filter.$text = { $search: keyword };
    }

    // Get products with filters
    const products = await Product.find(filter)
      .sort({ popularity: -1 })
      .limit(Number(limit));

    res.json({
      success: true,
      count: products.length,
      data: products
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: 'Server Error: ' + err.message
    });
  }
});

// @desc    Get smart gift recommendations
// @route   POST /api/products/recommend
// @access  Public
exports.recommendProducts = asyncHandler(async (req, res) => {
  try {
    const { message, chatHistory = [] } = req.body;
    
    // Extract keywords from chat history (simplified NLP)
    const keywords = extractKeywordsFromChat([...chatHistory, { text: message }]);
    
    // Get recommendations (using the model's static method)
    const recommendations = await Product.recommendGifts({
      keywords,
      ...extractFiltersFromMessage(message)
    });

    if (!recommendations.length) {
      return res.json({
        success: true,
        message: "I couldn't find perfect matches, but here are some popular gifts:",
        data: await Product.find().sort('-popularity').limit(3)
      });
    }

    res.json({
      success: true,
      data: recommendations
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: 'Recommendation failed: ' + err.message
    });
  }
});

// Helper: Extract gift filters from natural language
function extractFiltersFromMessage(message) {
  const filters = {};
  const lowerMsg = message.toLowerCase();

  // Price extraction (simple pattern)
  const priceMatch = lowerMsg.match(/(under|below|less than) (\$|€|£)?(\d+)/);
  if (priceMatch) filters.budget = Number(priceMatch[3]);

  // Recipient extraction
  const recipients = ['mother', 'father', 'wife', 'husband', 'girlfriend', 'boyfriend', 'friend'];
  recipients.forEach(recipient => {
    if (lowerMsg.includes(recipient)) filters.recipient = recipient;
  });

  // Occasion extraction
  const occasions = ['birthday', 'anniversary', 'valentine', 'christmas', 'graduation'];
  occasions.forEach(occasion => {
    if (lowerMsg.includes(occasion)) filters.occasion = occasion;
  });

  return filters;
}

// Helper: Extract keywords from conversation
function extractKeywordsFromChat(chatHistory) {
  const keywords = new Set();
  const commonWords = new Set(['the', 'and', 'for', 'with', 'this', 'that']);

  chatHistory.forEach(entry => {
    entry.text.toLowerCase().split(/\s+/).forEach(word => {
      if (word.length > 3 && !commonWords.has(word)) {
        keywords.add(word);
      }
    });
  });

  return Array.from(keywords);
}

// @desc    Update product popularity
// @route   PUT /api/products/:id/popularity
// @access  Private (Admin)
exports.updatePopularity = asyncHandler(async (req, res) => {
  try {
    const product = await Product.findOneAndUpdate(
      { productId: req.params.id },
      { $inc: { popularity: 1 } },
      { new: true }
    );

    if (!product) {
      return res.status(404).json({
        success: false,
        error: 'Product not found'
      });
    }

    res.json({
      success: true,
      data: product
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: 'Update failed: ' + err.message
    });
  }
});

// @desc    Add new product
// @route   POST /api/products
// @access  Private (Admin)
exports.addProduct = asyncHandler(async (req, res) => {
  try {
    const product = new Product({
      ...req.body,
      lastUpdated: new Date()
    });

    await product.save();

    res.status(201).json({
      success: true,
      data: product
    });
  } catch (err) {
    if (err instanceof mongoose.Error.ValidationError) {
      return res.status(400).json({
        success: false,
        error: 'Validation Error: ' + Object.values(err.errors).map(e => e.message).join(', ')
      });
    }
    res.status(500).json({
      success: false,
      error: 'Create failed: ' + err.message
    });
  }
});