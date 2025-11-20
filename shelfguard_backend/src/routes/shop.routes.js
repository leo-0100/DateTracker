const express = require('express');
const { body } = require('express-validator');
const shopController = require('../controllers/shop.controller');
const { authMiddleware, requireShop } = require('../middleware/auth');
const { validate } = require('../middleware/validation');

const router = express.Router();

// All routes require authentication
router.use(authMiddleware);

/**
 * @route   GET /api/v1/shops/settings
 * @desc    Get shop settings
 * @access  Private
 */
router.get('/settings', requireShop, shopController.getShopSettings);

/**
 * @route   PUT /api/v1/shops/settings
 * @desc    Update shop settings
 * @access  Private
 */
router.put(
  '/settings',
  requireShop,
  [
    body('defaultNotificationDays').optional().isArray().withMessage('Must be an array'),
    body('notificationTime').optional().matches(/^([01]\d|2[0-3]):([0-5]\d)$/).withMessage('Invalid time format (HH:mm)'),
    body('notificationsEnabled').optional().isBoolean().withMessage('Must be boolean'),
    validate,
  ],
  shopController.updateShopSettings
);

/**
 * @route   GET /api/v1/shops/custom-fields
 * @desc    Get all custom fields
 * @access  Private
 */
router.get('/custom-fields', requireShop, shopController.getCustomFields);

/**
 * @route   POST /api/v1/shops/custom-fields
 * @desc    Create custom field
 * @access  Private
 */
router.post(
  '/custom-fields',
  requireShop,
  [
    body('name').trim().notEmpty().withMessage('Field name is required'),
    body('fieldType')
      .isIn(['text', 'number', 'date', 'boolean', 'select'])
      .withMessage('Invalid field type'),
    body('required').optional().isBoolean().withMessage('Must be boolean'),
    body('selectOptions').optional().isArray().withMessage('Must be an array'),
    validate,
  ],
  shopController.createCustomField
);

/**
 * @route   PUT /api/v1/shops/custom-fields/:id
 * @desc    Update custom field
 * @access  Private
 */
router.put(
  '/custom-fields/:id',
  requireShop,
  [
    body('name').optional().trim().notEmpty().withMessage('Field name cannot be empty'),
    body('fieldType')
      .optional()
      .isIn(['text', 'number', 'date', 'boolean', 'select'])
      .withMessage('Invalid field type'),
    body('required').optional().isBoolean().withMessage('Must be boolean'),
    body('selectOptions').optional().isArray().withMessage('Must be an array'),
    validate,
  ],
  shopController.updateCustomField
);

/**
 * @route   DELETE /api/v1/shops/custom-fields/:id
 * @desc    Delete custom field
 * @access  Private
 */
router.delete('/custom-fields/:id', requireShop, shopController.deleteCustomField);

module.exports = router;
