const express = require('express');
const router = express.Router();

// Import the controller
const { addToCart, getCart,
    removeFromCart,
    updateCartItem } = require('../controllers/cartController');

// Route: POST /api/cart/add
router.post('/add', addToCart);

// Get user's cart
router.get('/:userId', getCart);

// Remove item from cart
router.delete('/remove', removeFromCart);

// Update item quantity
router.put('/update', updateCartItem);


module.exports = router;
