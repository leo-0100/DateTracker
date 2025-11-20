const express = require('express');
const { body, query } = require('express-validator');
const productController = require('../controllers/product.controller');
const { authMiddleware, requireShop } = require('../middleware/auth');
const { validate } = require('../middleware/validation');

const router = express.Router();

// All routes require authentication and shop membership
router.use(authMiddleware, requireShop);

/**
 * @route   GET /api/v1/products
 * @desc    Get all products for a shop with filters
 * @access  Private
 */
router.get('/', productController.getProducts);

/**
 * @route   GET /api/v1/products/expiring-soon
 * @desc    Get products expiring soon
 * @access  Private
 */
router.get('/expiring-soon', productController.getExpiringSoon);

/**
 * @route   GET /api/v1/products/expired
 * @desc    Get expired products
 * @access  Private
 */
router.get('/expired', productController.getExpired);

/**
 * @route   GET /api/v1/products/dashboard-stats
 * @desc    Get dashboard statistics
 * @access  Private
 */
router.get('/dashboard-stats', productController.getDashboardStats);

/**
 * @route   GET /api/v1/products/:id
 * @desc    Get single product by ID
 * @access  Private
 */
router.get('/:id', productController.getProduct);

/**
 * @route   POST /api/v1/products
 * @desc    Create new product
 * @access  Private
 */
router.post(
  '/',
  [
    body('name').trim().notEmpty().withMessage('Product name is required'),
    body('expiryDate').isISO8601().withMessage('Valid expiry date is required'),
    body('quantity').optional().isNumeric().withMessage('Quantity must be a number'),
    body('unit').optional().trim(),
    body('status')
      .optional()
      .isIn(['active', 'disposed', 'sold', 'expired'])
      .withMessage('Invalid status'),
    validate,
  ],
  productController.createProduct
);

/**
 * @route   PUT /api/v1/products/:id
 * @desc    Update product
 * @access  Private
 */
router.put(
  '/:id',
  [
    body('name').optional().trim().notEmpty().withMessage('Product name cannot be empty'),
    body('expiryDate').optional().isISO8601().withMessage('Valid expiry date is required'),
    body('quantity').optional().isNumeric().withMessage('Quantity must be a number'),
    body('status')
      .optional()
      .isIn(['active', 'disposed', 'sold', 'expired'])
      .withMessage('Invalid status'),
    validate,
  ],
  productController.updateProduct
);

/**
 * @route   DELETE /api/v1/products/:id
 * @desc    Delete product
 * @access  Private
 */
router.delete('/:id', productController.deleteProduct);

module.exports = router;
