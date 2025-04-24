const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

// Connect to MongoDB
console.log("MongoDB URI:", process.env.MONGO_URI);
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log("✅ Connected to MongoDB Atlas"))
    .catch(err => console.error("❌ MongoDB Connection Error:", err));

// Import routes
const userRoutes = require('./routes/userRoutes');
app.use('/api', userRoutes);

const categoryRoutes = require('./routes/categories');
app.use('/api/categories', categoryRoutes);

// ✅ ADD THIS:
const productRoutes = require('./routes/productRoutes');
app.use('/api/products', productRoutes);  // <-- Now this route works!

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
