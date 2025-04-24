const express = require('express');
const router = express.Router();
const {
  getProducts,
  addProduct,
  recommendProducts,
  updatePopularity
} = require('../controllers/productController'); // Destructured import

const Product = require('../models/Product');
router.get('/categories', (req, res) => {
  const categories = Product.schema.path('category').enumValues;
  res.json({ categories });
});




// Basic routes
router.post('/', addProduct);
router.get('/', getProducts);

// Recommendation engine
router.post('/recommend', recommendProducts);

// Popularity tracking
router.put('/:id/popularity', updatePopularity);

module.exports = router;