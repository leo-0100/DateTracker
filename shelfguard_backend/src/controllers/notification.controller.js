const { NotificationLog, Product } = require('../models');
const { Op } = require('sequelize');
const logger = require('../utils/logger');

/**
 * Get notification logs for a shop
 */
exports.getNotifications = async (req, res, next) => {
  try {
    const { shopId } = req;
    const { page = 1, limit = 20, unreadOnly = false } = req.query;

    const where = { shopId };
    if (unreadOnly === 'true') {
      where.readAt = null;
    }

    const offset = (page - 1) * limit;

    const { count, rows: notifications } = await NotificationLog.findAndCountAll({
      where,
      include: [
        {
          model: Product,
          as: 'product',
          attributes: ['id', 'name', 'barcode', 'expiryDate'],
        },
      ],
      order: [['sentAt', 'DESC']],
      limit: parseInt(limit),
      offset,
    });

    res.json({
      success: true,
      data: {
        notifications,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          totalPages: Math.ceil(count / limit),
        },
      },
    });
  } catch (error) {
    logger.error('Get notifications error:', error);
    next(error);
  }
};

/**
 * Mark notification as read
 */
exports.markAsRead = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { shopId } = req;

    const notification = await NotificationLog.findOne({
      where: { id, shopId },
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found',
      });
    }

    await notification.update({ readAt: new Date() });

    res.json({
      success: true,
      message: 'Notification marked as read',
    });
  } catch (error) {
    logger.error('Mark notification as read error:', error);
    next(error);
  }
};

/**
 * Mark all notifications as read
 */
exports.markAllAsRead = async (req, res, next) => {
  try {
    const { shopId } = req;

    await NotificationLog.update(
      { readAt: new Date() },
      {
        where: {
          shopId,
          readAt: null,
        },
      }
    );

    res.json({
      success: true,
      message: 'All notifications marked as read',
    });
  } catch (error) {
    logger.error('Mark all as read error:', error);
    next(error);
  }
};

/**
 * Get unread notification count
 */
exports.getUnreadCount = async (req, res, next) => {
  try {
    const { shopId } = req;

    const count = await NotificationLog.count({
      where: {
        shopId,
        readAt: null,
      },
    });

    res.json({
      success: true,
      data: {
        count,
      },
    });
  } catch (error) {
    logger.error('Get unread count error:', error);
    next(error);
  }
};
