const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: String,
  email: { type: String, unique: true },
  password: String,
  idNumber: String,
  age: Number,
  phoneNumber: String,
  dateOfBirth: Date,
  description: String,
  gender: String,
  role: { type: String, enum: ['user', 'Owner', 'admin'], default: 'Owner' }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);