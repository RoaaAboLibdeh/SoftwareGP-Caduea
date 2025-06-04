const express = require('express');
const router = express.Router();
const { 
    addToFavorites, 
    removeFromFavorites, 
    getFavorites 
} = require('../controllers/favoriteController');

// Add product to favorites
router.post('/add', addToFavorites);

// Remove product from favorites
router.delete('/:userId/items/:productId', removeFromFavorites); // DELETE /api/favorites/123/items/456

// Get all favorites for a user
router.get('/:userId', getFavorites);

module.exports = router;