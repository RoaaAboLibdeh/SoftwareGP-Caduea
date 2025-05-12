// routes/categories.js
const express = require('express');
const router = express.Router();
const Category = require('../models/Category');
const Product = require('../models/Product'); // ✅ Declare ONLY ONCE
const fs = require('fs');
const path = require('path');
const multer = require('multer');

// Configure multer for image uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    const filename = `${Date.now()}${ext}`;
    cb(null, filename);
  }
});
const upload = multer({ storage });

// GET all categories
router.get('/', async (req, res) => {
  try {
    const categories = await Category.find({ isActive: true });
    const categoriesWithFullUrls = categories.map(category => ({
      ...category.toObject(),
      image: category.image ? `/uploads/${category.image}` : null
    }));
    res.json({ categories: categoriesWithFullUrls });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST new category
router.post('/', async (req, res) => {
  try {
    const { name, icon, image } = req.body;
    const newCategory = new Category({ name, icon, image });
    await newCategory.save();
    res.status(201).json({
      ...newCategory.toObject(),
      image: newCategory.image ? `/uploads/${newCategory.image}` : null
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE a category
router.delete('/:id', async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);
    if (!category) return res.status(404).json({ message: 'Category not found' });

    if (category.image) {
      const imagePath = path.join(__dirname, '../uploads', category.image);
      if (fs.existsSync(imagePath)) {
        fs.unlinkSync(imagePath);
      }
    }

    await Category.findByIdAndDelete(req.params.id);
    res.json({ message: 'Category deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// PUT update category with optional image
router.put('/:id', upload.single('image'), async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);
    if (!category) return res.status(404).json({ message: 'Category not found' });

    const { name, icon } = req.body;
    if (name) category.name = name;
    if (icon) category.icon = icon;

    if (req.file) {
      if (category.image) {
        const oldImagePath = path.join(__dirname, '../uploads', category.image);
        if (fs.existsSync(oldImagePath)) {
          fs.unlinkSync(oldImagePath);
        }
      }
      category.image = req.file.filename;
    }

    await category.save();
    res.json({
      ...category.toObject(),
      image: category.image ? `/uploads/${category.image}` : null
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET products by category ID
router.get('/:id', async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);
const products = await Product.find({ category: category._id });

    res.json({ products });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
