const Message = require('../models/Message');
const User = require('../models/User');
const { classify, extractFiltersFromMessage, getGiftRecommendations, generateResponse } = require('../services/nlpService');

exports.processMessage = async (req, res) => {
  try {
    const { userId, avatarId, message } = req.body;

    // Save user message
    const userMessage = new Message({
        userId,
        avatarId,
        text: message,
        isAvatar: false
      });
      await userMessage.save();

    // Process with enhanced NLP
    const intent = classify(message);
    const filters = extractFiltersFromMessage(message);
    const products = await getGiftRecommendations(filters);
    const responseText = await generateResponse(intent, filters, products);

    // Save avatar response
    const avatarMessage = new Message({
        userId,
        avatarId,
        text: responseText,
        isAvatar: true,
        metadata: { intent, filters }
      });
      await avatarMessage.save();
  
      res.json({
        response: responseText,
        intent,
        filters,
        products: products.map(p => ({ name: p.name, price: p.price }))
      });
  
    } catch (error) {
      console.error('Error processing message:', error);
      res.status(500).json({ error: 'Failed to process message' });
    }
  };

exports.getChatHistory = async (req, res) => {
  try {
    const { userId, avatarId, limit = 20 } = req.query;
    
    const messages = await Message.find({ userId, avatarId })
      .sort({ timestamp: -1 })
      .limit(parseInt(limit))
      .exec();

    res.json(messages.reverse());
  } catch (error) {
    console.error('Error fetching chat history:', error);
    res.status(500).json({ error: 'Failed to fetch chat history' });
  }
};