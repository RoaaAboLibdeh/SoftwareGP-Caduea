// controllers/ownerController.js
const mongoose = require('mongoose');
const Owner = require('../models/Owner');  // Assuming you have an Owner model
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
require('dotenv').config();

// Controller to create a new owner
const User = require('../models/User.js');

// Add new owner (by admin)
exports.addOwner = async (req, res) => {
  try {
    const { name, email, password, idNumber, age, phoneNumber, dateOfBirth, description, gender } = req.body;

    const existing = await User.findOne({ email });
    if (existing) return res.status(400).json({ message: 'Email already exists' });

    const hashedPassword = await bcrypt.hash(password, 10);

    const newOwner = new User({
      name,
      email,
      password: hashedPassword,
      idNumber,
      age,
      phoneNumber,
      dateOfBirth,
      description,
      gender,
      role: 'Owner'
    });

    await newOwner.save();
    res.status(201).json({ message: 'Owner added successfully', owner: newOwner });

  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

// Get single owner
exports.getOwnerById = async (req, res) => {
  try {
    const owner = await User.findOne({ _id: req.params.id, role: 'Owner' });
    if (!owner) return res.status(404).json({ message: 'Owner not found' });

    res.status(200).json(owner);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

// Update owner
exports.updateOwner = async (req, res) => {
  try {
    let updates = req.body;

    // Trim the id parameter to remove any extra whitespace or newline characters
    const ownerId = req.params.id.trim();

    // If password is being updated, hash it
    if (updates.password) {
      updates.password = await bcrypt.hash(updates.password, 10);
    }

    // Find and update the owner based on the provided id and role 'Owner'
    const updatedOwner = await User.findOneAndUpdate(
      { _id: ownerId, role: 'Owner' },  // Ensure it's an Owner
      updates,  // Apply the updates
      { new: true }  // Return the updated document
    );

    // If no owner found, return a 404 error
    if (!updatedOwner) {
      return res.status(404).json({ message: 'Owner not found' });
    }

    // Send back the updated owner data
    res.status(200).json({ message: 'Owner updated', owner: updatedOwner });

  } catch (err) {
    console.error(err);  // Log the error for debugging
    res.status(500).json({ message: 'Server error' });
  }
};


exports.getAllOwners = async (req, res) => {
  try {
    const owners = await User.find({ role: 'Owner' });  // Find owners based on the role
    res.status(200).json({ owners });
  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ message: 'Error retrieving owners', error: err.message });
  }
};

