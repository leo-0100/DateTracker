const admin = require('firebase-admin');
const config = require('../config/config');
const logger = require('../utils/logger');

let initialized = false;

/**
 * Initialize Firebase Admin SDK
 */
const initialize = () => {
  try {
    if (initialized) {
      return;
    }

    // Check if Firebase credentials are provided
    if (!config.firebase.projectId || !config.firebase.privateKey || !config.firebase.clientEmail) {
      logger.warn('Firebase credentials not configured. Push notifications will not work.');
      return;
    }

    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: config.firebase.projectId,
        privateKey: config.firebase.privateKey.replace(/\\n/g, '\n'),
        clientEmail: config.firebase.clientEmail,
      }),
    });

    initialized = true;
    logger.info('✅ Firebase Admin SDK initialized');
  } catch (error) {
    logger.error('Failed to initialize Firebase Admin SDK:', error);
  }
};

/**
 * Send push notification to a user
 * @param {string} userId - User ID
 * @param {object} notification - Notification payload
 * @param {string} notification.title - Notification title
 * @param {string} notification.body - Notification body
 * @param {object} notification.data - Additional data
 */
const sendNotification = async (userId, notification) => {
  try {
    if (!initialized) {
      logger.warn('Firebase not initialized. Skipping notification.');
      return null;
    }

    // In a production app, you would store FCM tokens for each user
    // For now, we'll use a topic-based approach
    const topic = `user_${userId}`;

    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data || {},
      topic,
    };

    const response = await admin.messaging().send(message);
    logger.info(`Notification sent successfully: ${response}`);
    return response;
  } catch (error) {
    logger.error('Error sending notification:', error);
    throw error;
  }
};

/**
 * Subscribe device token to user topic
 * @param {string} token - FCM device token
 * @param {string} userId - User ID
 */
const subscribeToUserTopic = async (token, userId) => {
  try {
    if (!initialized) {
      logger.warn('Firebase not initialized. Cannot subscribe to topic.');
      return null;
    }

    const topic = `user_${userId}`;
    const response = await admin.messaging().subscribeToTopic([token], topic);
    logger.info(`Token subscribed to topic ${topic}`);
    return response;
  } catch (error) {
    logger.error('Error subscribing to topic:', error);
    throw error;
  }
};

/**
 * Unsubscribe device token from user topic
 * @param {string} token - FCM device token
 * @param {string} userId - User ID
 */
const unsubscribeFromUserTopic = async (token, userId) => {
  try {
    if (!initialized) {
      logger.warn('Firebase not initialized. Cannot unsubscribe from topic.');
      return null;
    }

    const topic = `user_${userId}`;
    const response = await admin.messaging().unsubscribeFromTopic([token], topic);
    logger.info(`Token unsubscribed from topic ${topic}`);
    return response;
  } catch (error) {
    logger.error('Error unsubscribing from topic:', error);
    throw error;
  }
};

// Initialize on module load
initialize();

module.exports = {
  initialize,
  sendNotification,
  subscribeToUserTopic,
  unsubscribeFromUserTopic,
};
