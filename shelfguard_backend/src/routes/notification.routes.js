const express = require('express');
const notificationController = require('../controllers/notification.controller');
const { authMiddleware, requireShop } = require('../middleware/auth');

const router = express.Router();

// All routes require authentication and shop membership
router.use(authMiddleware, requireShop);

/**
 * @route   GET /api/v1/notifications
 * @desc    Get notification logs for a shop
 * @access  Private
 */
router.get('/', notificationController.getNotifications);

/**
 * @route   GET /api/v1/notifications/unread-count
 * @desc    Get unread notification count
 * @access  Private
 */
router.get('/unread-count', notificationController.getUnreadCount);

/**
 * @route   PUT /api/v1/notifications/:id/read
 * @desc    Mark notification as read
 * @access  Private
 */
router.put('/:id/read', notificationController.markAsRead);

/**
 * @route   PUT /api/v1/notifications/read-all
 * @desc    Mark all notifications as read
 * @access  Private
 */
router.put('/read-all', notificationController.markAllAsRead);

module.exports = router;
