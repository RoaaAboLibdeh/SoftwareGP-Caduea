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
    }).populate('category').lean();

    res.json(products);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});


router.get('/category/:categoryId', async (req, res) => {
  try {
    const products = await Product.find({ category: req.params.categoryId });
    res.json({ products });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.get('/random-box', async (req, res) => {
  try {
    const { priceTier, userId } = req.query;
    
    // Determine price range based on tier
    let minPrice, maxPrice;
    if (priceTier == 10) {
      minPrice = 5;
      maxPrice = 10;
    } else if (priceTier == 20) {
      minPrice = 15;
      maxPrice = 20;
    } else if (priceTier == 50) {
      minPrice = 30;
      maxPrice = 50;
    }

    // Get random products that match the price range
    const products = await Product.aggregate([
      { 
        $match: { 
          price: { $gte: minPrice, $lte: maxPrice },
          stock: { $gt: 0 } // Only products in stock
        }
      },
      { $sample: { size: priceTier == 10 ? 2 : priceTier == 20 ? 3 : 5 } },
      { $sort: { popularity: -1 } }
    ]);

    res.json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
