const express = require('express');
const router = express.Router();
const ownerController = require('../controllers/ownerController');

// Add a new owner (admin only)
router.post('/add', ownerController.addOwner);

// Get a list of all owners
router.get('/all', ownerController.getAllOwners);

// Get details of a specific owner by ID
router.get('/get/:id', ownerController.getOwnerById);

// Update a specific owner by ID
router.put('/update/:id', ownerController.updateOwner);



module.exports = router;
