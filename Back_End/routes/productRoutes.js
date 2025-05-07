const express = require('express');
const { protect, adminOrOwner} = require('../middleware/auth');
const upload = require('../middleware/multer'); 

const multer = require('multer');
const router = express.Router();
const {
  getProducts,
  addProduct,
  recommendProducts,
  deleteProduct,
  updatePopularity
} = require('../controllers/productController'); // Destructured import

const Product = require('../models/Product');
router.get('/categories', (req, res) => {
  const categories = Product.schema.path('category').enumValues;
  res.json({ categories });
});
// Basic routes
router.post('/addproduct', upload.array('images', 3), addProduct);
router.get('/', getProducts);

// Recommendation engine
router.post('/recommend', recommendProducts);

// Popularity tracking
router.put('/:id/popularity', updatePopularity);

router.delete('/:id', deleteProduct); // ✅ Already imported at the top

// Route: GET /products/discounted
// GET /api/products/popular?limit=10
router.get('/popular', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const popularProducts = await Product.find({})
      .sort({ popularity: -1 }) // Descending order
      .limit(limit);

    res.json(popularProducts);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// routes/product.js
router.get('/search', async (req, res) => {
  try {
    const { q } = req.query;
    const regex = new RegExp(q, 'i');

    const products = await Product.find({
      $or: [
        { keywords: regex },
        { description: regex },
        { name: regex },
        { occasion: regex },
        { recipientType: regex }
      ]
    }).populate('category');

    res.json(products);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});






module.exports = router;
