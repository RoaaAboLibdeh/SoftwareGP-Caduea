const express = require('express');
const router = express.Router();
const Order = require('../models/Orders');

router.post('/create', async (req, res) => {
  try {
    const newOrder = new Order(req.body);
    await newOrder.save();
    res.status(201).json({ message: 'Order created successfully', order: newOrder });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Failed to create order' });
  }
});

router.get('/user/:userId', async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.params.userId }).sort({ createdAt: -1 });
    res.status(200).json(orders);
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch orders' });
  }
});

module.exports = router;