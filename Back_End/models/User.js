const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  avatar: { type: String, default: "" },
  role: {
    type: String,
    enum: ['customer', 'admin', 'owner'],
    default: 'customer'
  },
  createdAt: { type: Date, default: Date.now },
  token: { type: String, default: "" },  // Token field added
  userId: { type: Number, required: true,index: true} 
});

userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

// Force-delete the old model if it exists (for dev environments)
delete mongoose.models.User;
const User = mongoose.model('User', userSchema);

module.exports = User;
