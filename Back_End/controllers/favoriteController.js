const Favorite = require('../models/Favorite');
const Product = require('../models/Product');
const mongoose = require('mongoose');

const addToFavorites = async (req, res) => {
    const { userId, productId } = req.body;

    // Validate input
    if (!userId || !productId) {
        return res.status(400).json({ message: 'userId and productId are required' });
    }

    if (!mongoose.Types.ObjectId.isValid(userId)) {
        return res.status(400).json({ message: 'Invalid userId format' });
    }

    if (!mongoose.Types.ObjectId.isValid(productId)) {
        return res.status(400).json({ message: 'Invalid productId format' });
    }

    try {
        console.log('Searching for product:', productId);
        const product = await Product.findById(productId);
        if (!product) {
            console.log('Product not found in database');
            return res.status(404).json({ message: 'Product not found' });
        }

        let favorite = await Favorite.findOne({ user: userId });

        if (!favorite) {
            favorite = new Favorite({
                user: userId,
                items: [{ product: productId }]
            });
        } else {
            const exists = favorite.items.some(item => item.product.toString() === productId);
            if (exists) {
                return res.status(400).json({ message: 'Product already in favorites' });
            }
            favorite.items.push({ product: productId });
        }

        await favorite.save();
        res.status(200).json(favorite);

    } catch (error) {
        console.error('Error in addToFavorites:', error);
        res.status(500).json({ message: error.message });
    }
};

const removeFromFavorites = async (req, res) => {
    const { userId, productId } = req.body;

    // Validate input
    if (!userId || !productId) {
        return res.status(400).json({ message: 'userId and productId are required' });
    }

    try {
        const favorite = await Favorite.findOne({ user: userId });
        if (!favorite) {
            return res.status(404).json({ message: 'Favorite list not found' });
        }

        const initialCount = favorite.items.length;
        favorite.items = favorite.items.filter(item => item.product.toString() !== productId);

        if (favorite.items.length === initialCount) {
            return res.status(404).json({ message: 'Product not found in favorites' });
        }

        await favorite.save();
        res.status(200).json(favorite);

    } catch (error) {
        console.error('Error in removeFromFavorites:', error);
        res.status(500).json({ message: error.message });
    }
};

const getFavorites = async (req, res) => {
    const { userId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
        return res.status(400).json({ message: 'Invalid userId format' });
    }

    try {
        const favorite = await Favorite.findOne({ user: userId }).populate('items.product');
        if (!favorite) {
            return res.status(200).json({ items: [] });
        }
        res.status(200).json(favorite);
    } catch (error) {
        console.error('Error in getFavorites:', error);
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    addToFavorites,
    removeFromFavorites,
    getFavorites
};