const cron = require('node-cron');
const { Product, Shop, User, NotificationLog } = require('../models');
const { Op } = require('sequelize');
const config = require('../config/config');
const logger = require('../utils/logger');
const firebaseService = require('./firebaseService');

/**
 * Check products and send expiry notifications
 */
const checkAndSendNotifications = async () => {
  try {
    logger.info('Starting notification check...');

    const shops = await Shop.findAll({
      where: { notificationsEnabled: true },
    });

    for (const shop of shops) {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      // Get notification days for this shop
      const notificationDays = shop.defaultNotificationDays || [7, 3, 0];

      for (const days of notificationDays) {
        const targetDate = new Date(today);
        targetDate.setDate(targetDate.getDate() + days);

        // Find products expiring on target date
        const products = await Product.findAll({
          where: {
            shopId: shop.id,
            status: 'active',
            expiryDate: targetDate.toISOString().split('T')[0],
          },
        });

        for (const product of products) {
          // Check if notification already sent today for this product and days
          const existingNotification = await NotificationLog.findOne({
            where: {
              productId: product.id,
              daysToExpiry: days,
              sentAt: {
                [Op.gte]: today,
              },
            },
          });

          if (existingNotification) {
            continue; // Skip if already sent
          }

          // Determine notification type
          let notificationType;
          let title;
          let body;

          if (days === 0) {
            notificationType = 'expired';
            title = `⚠️ Product Expiring Today`;
            body = `${product.name} is expiring today!`;
          } else if (days <= 3) {
            notificationType = 'expiry_critical';
            title = `🚨 Critical: ${days} Days to Expiry`;
            body = `${product.name} will expire in ${days} day${days > 1 ? 's' : ''}`;
          } else {
            notificationType = 'expiry_warning';
            title = `⏰ ${days} Days to Expiry`;
            body = `${product.name} will expire in ${days} days`;
          }

          // Create notification log
          await NotificationLog.create({
            productId: product.id,
            shopId: shop.id,
            notificationType,
            daysToExpiry: days,
            title,
            body,
          });

          // Send push notification to shop users
          const users = await User.findAll({
            where: { shopId: shop.id },
          });

          for (const user of users) {
            try {
              await firebaseService.sendNotification(user.id, {
                title,
                body,
                data: {
                  productId: product.id,
                  daysToExpiry: days.toString(),
                  type: notificationType,
                },
              });
            } catch (error) {
              logger.error(`Failed to send notification to user ${user.id}:`, error);
            }
          }

          logger.info(`Notification sent for product ${product.id} (${days} days)`);
        }
      }
    }

    logger.info('Notification check completed');
  } catch (error) {
    logger.error('Error in notification scheduler:', error);
  }
};

/**
 * Initialize notification scheduler
 */
const initializeScheduler = () => {
  if (!config.notificationScheduler.enabled) {
    logger.info('Notification scheduler is disabled');
    return;
  }

  // Schedule cron job (default: daily at 9:00 AM)
  const cronExpression = config.notificationScheduler.cron;

  cron.schedule(cronExpression, async () => {
    logger.info('Running scheduled notification check');
    await checkAndSendNotifications();
  });

  logger.info(`Notification scheduler initialized with cron: ${cronExpression}`);

  // Optional: Run immediately on startup
  // checkAndSendNotifications();
};

module.exports = {
  initializeScheduler,
  checkAndSendNotifications,
};
