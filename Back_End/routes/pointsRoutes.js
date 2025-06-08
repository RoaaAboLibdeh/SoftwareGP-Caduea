// routes/pointsRoutes.js
const express = require('express');
const router = express.Router();
const DiscountPoints = require('../models/DiscountPoints');

// Get user's points
router.get('/:userId', async (req, res) => {
  try {
    const points = await DiscountPoints.findOne({ user: req.params.userId });
    if (!points) {
      return res.status(200).json({
        totalPoints: 0,
        availablePoints: 0,
        lifetimePointsEarned: 0,
        lifetimePointsUsed: 0
      });
    }
    res.json(points);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Redeem points
router.post('/redeem', async (req, res) => {
  try {
    const { userId, pointsToRedeem } = req.body;
    
    if (!userId || !pointsToRedeem || pointsToRedeem <= 0) {
      return res.status(400).json({ message: 'Invalid request' });
    }
    
    const pointsRecord = await DiscountPoints.findOne({ user: userId });
    if (!pointsRecord || pointsRecord.availablePoints < pointsToRedeem) {
      return res.status(400).json({ message: 'Not enough points available' });
    }
    
    pointsRecord.availablePoints -= pointsToRedeem;
    pointsRecord.lifetimePointsUsed += pointsToRedeem;
    await pointsRecord.save();
    
    res.json({ 
      message: 'Points redeemed successfully',
      newAvailablePoints: pointsRecord.availablePoints
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// TEMPORARY: Create test DiscountPoints
router.get('/test-create/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const points = new DiscountPoints({
      user: userId,
      totalPoints: 100,
      availablePoints: 100,
      lifetimePointsEarned: 100,
      lifetimePointsUsed: 0
    });

    await points.save();
    res.json({ message: 'DiscountPoints test data created!', points });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});




module.exports = router;