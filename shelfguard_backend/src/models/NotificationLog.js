const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const NotificationLog = sequelize.define('NotificationLog', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  productId: {
    type: DataTypes.UUID,
    allowNull: false,
    field: 'product_id',
  },
  shopId: {
    type: DataTypes.UUID,
    allowNull: false,
    field: 'shop_id',
  },
  userId: {
    type: DataTypes.UUID,
    field: 'user_id',
  },
  notificationType: {
    type: DataTypes.STRING,
    allowNull: false,
    field: 'notification_type',
    validate: {
      isIn: [['expiry_warning', 'expiry_critical', 'expired']],
    },
  },
  daysToExpiry: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'days_to_expiry',
  },
  sentAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    field: 'sent_at',
  },
  readAt: {
    type: DataTypes.DATE,
    field: 'read_at',
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  body: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
}, {
  tableName: 'notifications_log',
  underscored: true,
  timestamps: false,
});

module.exports = NotificationLog;
