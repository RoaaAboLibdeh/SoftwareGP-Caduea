const jwt = require('jsonwebtoken');
const User = require('../models/User');
exports.protect = async (req, res, next) => {
    let token;
  
    // Check Authorization header
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }
  
    if (!token) {
      return res.status(401).json({ message: 'Not authorized, no token' });
    }
  
    try {
      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      // Get user from token
      req.user = await User.findById(decoded.id).select('-password');
      
      next();
    } catch (err) {
      res.status(401).json({ message: 'Not authorized, token failed' });
    }
  };

exports.admin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Admin access required' });
  }
  next();
};
exports.ownerOnly = (req, res, next) => {
  if (req.user.role !== 'Owner') {
    return res.status(403).json({ message: 'Owner access required' });
  }
  next();
};

// مشترك بين الادمن و الأونر
exports.adminOrOwner = (req, res, next) => {
  if (req.user.role !== 'admin' && req.user.role !== 'Owner') {
    return res.status(403).json({ message: 'Admin or Owner access required' });
  }
  next();
};