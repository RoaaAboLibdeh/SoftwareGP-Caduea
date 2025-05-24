const express = require('express');
const router = express.Router();
const BoxSelection = require('../models/BoxSelection');

router.post('/saveBoxChoice', async (req, res) => {
  const { userId, box, boxColor, lidColor, ribbonColor } = req.body;

  try {
    const newChoice = new BoxSelection({ userId, box, boxColor, lidColor, ribbonColor });
    await newChoice.save();
    res.status(200).json({ message: '✅ Choice saved' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: '❌ Saving failed' });
  }
});

router.get('/allChoices/:userId', async (req, res) => {
  try {
    const choices = await BoxSelection.find({ userId: req.params.userId });
    res.status(200).json(choices);
  } catch (err) {
    res.status(500).json({ message: '❌ Fetching failed' });
  }
});

module.exports = router;