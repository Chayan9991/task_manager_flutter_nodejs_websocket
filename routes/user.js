const express = require('express');
const User = require('../models/User');
const { verifyJWT } = require('../middleware/auth');

const router = express.Router();

router.get('/currentUser', verifyJWT, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('-password');
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    console.error('Error getting current user:', error.message);
    res.status(500).json({ msg: 'Server error' });
  }
});


router.get('/:id', async (req, res) => {
    try {
      const user = await User.findById(req.params.id).select('-password');
      if (!user) return res.status(404).json({ msg: 'User not found' });
      res.json(user);
    } catch (error) {
      console.error('Error fetching user by ID:', error.message);
      res.status(500).json({ msg: 'Server error' });
    }
  });
  

module.exports = router;
