const Review = require('../models/Review');
const Product = require('../models/Product');
const User = require('../models/User');

// Create a new review
exports.createReview = async (req, res) => {
  try {
    const { userId, productId, rating, comment } = req.body;

    console.log('Incoming review:', req.body); // 👈 Log incoming data

    // ... existing checks ...

    // Check for existing review
    const existingReview = await Review.findOne({ user: userId, product: productId });
    if (existingReview) {
      return res.status(400).json({
        success: false,
        error: 'You have already reviewed this product.',
      });
    }

    const review = new Review({ user: userId, product: productId, rating, comment });
    await review.save();

    const populatedReview = await Review.findById(review._id).populate('user', 'name avatar');

    return res.status(201).json({
      success: true,
      message: 'Review added successfully',
      data: {
        ...populatedReview.toObject(),
        userName: populatedReview.user.name,
        userAvatar: populatedReview.user.avatar,
      },
    });
  } catch (err) {
    console.error('❌ Backend error in createReview:', err); // 👈 Important
    res.status(500).json({ success: false, error: 'Server error: ' + err.message });
  }
};


// Get all reviews for a specific product
exports.getReviewsForProduct = async (req, res) => {
  try {
    const { productId } = req.params;

    // Validate product exists
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({ 
        success: false,
        error: 'Product not found' 
      });
    }

    // Get reviews with user details
    const reviews = await Review.find({ product: productId })
      .populate('user', 'name avatar')
      .sort({ createdAt: -1 });

    // Calculate average rating
    let averageRating = 0;
    if (reviews.length > 0) {
      const total = reviews.reduce((sum, review) => sum + review.rating, 0);
      averageRating = total / reviews.length;
    }

    // Transform data for better client consumption
    const transformedReviews = reviews.map(review => ({
      _id: review._id,
      rating: review.rating,
      comment: review.comment,
      createdAt: review.createdAt,
      userName: review.user.name,
      userAvatar: review.user.avatar
    }));

    res.json({ 
      success: true,
      count: transformedReviews.length,
      averageRating,
      data: transformedReviews 
    });

  } catch (error) {
    console.error('Error fetching reviews:', error);
    res.status(500).json({ 
      success: false,
      error: 'Failed to fetch reviews: ' + error.message 
    });
  }
};

// Delete a review
exports.deleteReview = async (req, res) => {
  try {
    const { reviewId } = req.params;

    const review = await Review.findByIdAndDelete(reviewId);

    if (!review) {
      return res.status(404).json({ 
        success: false,
        error: 'Review not found' 
      });
    }

    res.json({ 
      success: true,
      message: 'Review deleted successfully',
      deletedReview: review 
    });

  } catch (error) {
    console.error('Error deleting review:', error);
    res.status(500).json({ 
      success: false,
      error: 'Failed to delete review: ' + error.message 
    });
  }
};

// In ReviewController.js
exports.getReviewsByUser = async (req, res) => {
  try {
    const reviews = await Review.find({ user: req.params.userId })
      .populate('product', 'name price imageUrls')
      .sort({ createdAt: -1 });

    res.status(200).json({
      status: 'success',
      results: reviews.length,
      reviews
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: err.message
    });
  }
};