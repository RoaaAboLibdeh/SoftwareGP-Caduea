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
module.exports = router;
