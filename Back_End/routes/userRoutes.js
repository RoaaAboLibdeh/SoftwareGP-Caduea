const express = require('express');
const router = express.Router();
const User = require('../models/User');  // Import the User model
const userController = require('../controllers/userController');

router.post('/users/signup', userController.createUser); 
router.post('/users/login', userController.loginUser);   // Login
router.get('/users', userController.getAllUsers);  // Get all users
router.delete('/users/:id', userController.deleteUser);  // Delete user by ID

////////////////////////////////// to store avatar /////////////////////////
// In userRoutes.js - make sure the route is correct
router.put('/users/:id', async (req, res) => {
    try {
        const { avatar } = req.body;
        const user = await User.findByIdAndUpdate(
            req.params.id, 
            { avatar }, 
            { new: true }
        );

        if (!user) return res.status(404).json({ message: "User not found" });
        
        res.json({ message: "Avatar updated successfully", user });
    } catch (error) {
        res.status(500).json({ message: "Server error", error });
    }
});
////////////////////////////////// to store avatar /////////////////////////



router.get('/users/:id', async (req, res) => {
    try {
      const user = await User.findById(req.params.id);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      res.status(200).json(user);
    } catch (err) {
      res.status(500).json({ message: 'Error fetching user', error: err.message });
    }
  });



module.exports = router;
