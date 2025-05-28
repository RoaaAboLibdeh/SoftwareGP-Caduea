const express = require('express');
const router = express.Router();
const {
  classify,
  extractFiltersFromMessage,
  getGiftRecommendations,
  generateResponse
} = require('../services/nlpService');

router.post('/chat', async (req, res) => {
  const { message } = req.body;

  if (!message) {
    return res.status(400).json({ error: 'Message is required' });
  }

  const intent = classify(message);
  const filters = extractFiltersFromMessage(message);
  const products = await getGiftRecommendations(filters);
  const reply = await generateResponse(intent, filters, products);

  return res.json({
    message: reply,
    isProductRecommendation: products.length > 0
  });
});

module.exports = router;
