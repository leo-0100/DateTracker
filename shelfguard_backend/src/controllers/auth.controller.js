const jwt = require('jsonwebtoken');
const { User, Shop, RefreshToken } = require('../models');
const config = require('../config/config');
const logger = require('../utils/logger');

/**
 * Generate access token
 */
const generateAccessToken = (userId) => {
  return jwt.sign({ userId }, config.jwt.secret, {
    expiresIn: config.jwt.expiresIn,
  });
};

/**
 * Generate refresh token
 */
const generateRefreshToken = (userId) => {
  return jwt.sign({ userId }, config.jwt.refreshSecret, {
    expiresIn: config.jwt.refreshExpiresIn,
  });
};

/**
 * Register a new user and shop
 */
exports.signup = async (req, res, next) => {
  try {
    const { email, password, name, phone, shopName, shopDescription } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'User already exists with this email',
      });
    }

    // Hash password
    const passwordHash = await User.hashPassword(password);

    // Create user (without shop first due to circular dependency)
    const user = await User.create({
      email,
      passwordHash,
      name,
      phone,
      role: 'owner',
    });

    // Create shop
    const shop = await Shop.create({
      name: shopName || `${name}'s Shop`,
      description: shopDescription,
      ownerId: user.id,
    });

    // Update user with shop_id
    await user.update({ shopId: shop.id });

    // Generate tokens
    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    // Save refresh token
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);
    await RefreshToken.create({
      userId: user.id,
      token: refreshToken,
      expiresAt,
    });

    logger.info(`New user registered: ${email}`);

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          shopId: user.shopId,
        },
        shop: {
          id: shop.id,
          name: shop.name,
        },
        accessToken,
        refreshToken,
      },
    });
  } catch (error) {
    logger.error('Signup error:', error);
    next(error);
  }
};

/**
 * Login user
 */
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    // Check password
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    // Generate tokens
    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    // Save refresh token
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);
    await RefreshToken.create({
      userId: user.id,
      token: refreshToken,
      expiresAt,
    });

    logger.info(`User logged in: ${email}`);

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          shopId: user.shopId,
        },
        accessToken,
        refreshToken,
      },
    });
  } catch (error) {
    logger.error('Login error:', error);
    next(error);
  }
};

/**
 * Refresh access token
 */
exports.refreshToken = async (req, res, next) => {
  try {
    const { refreshToken: token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token is required',
      });
    }

    // Verify token
    const decoded = jwt.verify(token, config.jwt.refreshSecret);

    // Check if token exists in database
    const storedToken = await RefreshToken.findOne({
      where: { token, userId: decoded.userId },
    });

    if (!storedToken) {
      return res.status(401).json({
        success: false,
        message: 'Invalid refresh token',
      });
    }

    if (storedToken.isExpired()) {
      await storedToken.destroy();
      return res.status(401).json({
        success: false,
        message: 'Refresh token expired',
      });
    }

    // Generate new access token
    const accessToken = generateAccessToken(decoded.userId);

    res.json({
      success: true,
      message: 'Token refreshed successfully',
      data: {
        accessToken,
      },
    });
  } catch (error) {
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid refresh token',
      });
    }
    logger.error('Refresh token error:', error);
    next(error);
  }
};

/**
 * Logout user
 */
exports.logout = async (req, res, next) => {
  try {
    const { refreshToken: token } = req.body;

    if (token) {
      await RefreshToken.destroy({ where: { token } });
    }

    res.json({
      success: true,
      message: 'Logged out successfully',
    });
  } catch (error) {
    logger.error('Logout error:', error);
    next(error);
  }
};

/**
 * Get current user profile
 */
exports.getProfile = async (req, res, next) => {
  try {
    const user = await User.findByPk(req.userId, {
      include: [
        {
          model: Shop,
          as: 'shop',
          attributes: ['id', 'name', 'description', 'address', 'phone', 'email'],
        },
      ],
    });

    res.json({
      success: true,
      data: {
        user,
      },
    });
  } catch (error) {
    logger.error('Get profile error:', error);
    next(error);
  }
};
