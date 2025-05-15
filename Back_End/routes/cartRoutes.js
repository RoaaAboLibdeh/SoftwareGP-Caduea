const express = require('express');
const router = express.Router();

// Import the controller
const { addToCart } = require('../controllers/cartController');

// Route: POST /api/cart/add
router.post('/add', addToCart);

module.exports = router;
