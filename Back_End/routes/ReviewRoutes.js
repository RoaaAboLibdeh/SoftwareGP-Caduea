// routes/ReviewRoutes.js
const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/ReviewController');

// Route to create a new review
// POST /api/reviews
router.post('/', reviewController.createReview);

// Route to get all reviews for a specific product
// GET /api/products/:productId/reviews
// routes/ReviewRoutes.js
router.get('/products/:productId', reviewController.getReviewsForProduct);
// Route to delete a review
// DELETE /api/reviews/:reviewId
router.delete('/:reviewId', reviewController.deleteReview);

module.exports = router;