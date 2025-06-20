const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();
const ownerRoutes = require('./routes/ownerRoutes');
// const adminRoutes = require('./routes/adminRoutes'); // ✅ If using admin approve/reject
const productsRoutes = require('./routes/productRoutes');
const path = require('path');
const cartRoutes = require('./routes/cartRoutes');
const chatRoutes = require('./routes/chat');
const pointsRoutes = require('./routes/pointsRoutes'); // ✅ correct path

const app = express();
app.use(express.json());
app.use(cors());
app.use('/api', chatRoutes); // 👈 This enables /api/chat

// Connect to MongoDB
console.log("MongoDB URI:", process.env.MONGO_URI);
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log("✅ Connected to MongoDB Atlas"))
    .catch(err => console.error("❌ MongoDB Connection Error:", err));

// Import routes
const categoryRoutes = require('./routes/categories');
app.use('/api/categories', categoryRoutes);
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));


const userRoutes = require('./routes/userRoutes');
app.use('/api', userRoutes);
app.use('/api/owners', ownerRoutes);
// app.use('/api/admin', adminRoutes); // optional
// const categoryRoutes = require('./routes/categories');
// app.use('/api/categories', categoryRoutes);

// ✅ ADD THIS:
const productRoutes = require('./routes/productRoutes');
app.use('/api/products', productRoutes);  // <-- Now this route works!

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));


// Middleware
// app.use(express.json());

// Register route
app.use('/products', productRoutes);

// Start server
app.listen(3000, () => {
  console.log('Server running on port 5000');
});


const reviewRoutes = require('./routes/ReviewRoutes');

// app.use(express.json());
app.use('/api/reviews', reviewRoutes);

/// for Cart
app.use('/api/cart', cartRoutes);


//for favorite 
const favoriteRoutes = require('./routes/favoriteRoutes');
app.use('/api/favorites', favoriteRoutes);

///for box
const boxRoutes = require('./routes/boxRoutes');
app.use('/api/box', boxRoutes);

const orderRoutes = require('./routes/orderRoutes');
app.use('/api/orders', orderRoutes);

// ✅ Mount your points routes at /api/points
app.use('/api/points', pointsRoutes);