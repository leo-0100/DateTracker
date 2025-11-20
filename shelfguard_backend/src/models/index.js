const User = require('./User');
const Shop = require('./Shop');
const Product = require('./Product');
const CustomField = require('./CustomField');
const NotificationLog = require('./NotificationLog');
const RefreshToken = require('./RefreshToken');

// Define associations
// User - Shop (many-to-one)
User.belongsTo(Shop, { foreignKey: 'shopId', as: 'shop' });
Shop.hasMany(User, { foreignKey: 'shopId', as: 'users' });

// Shop - Owner (one-to-one)
Shop.belongsTo(User, { foreignKey: 'ownerId', as: 'owner' });

// Shop - Products (one-to-many)
Shop.hasMany(Product, { foreignKey: 'shopId', as: 'products', onDelete: 'CASCADE' });
Product.belongsTo(Shop, { foreignKey: 'shopId', as: 'shop' });

// Shop - CustomFields (one-to-many)
Shop.hasMany(CustomField, { foreignKey: 'shopId', as: 'customFields', onDelete: 'CASCADE' });
CustomField.belongsTo(Shop, { foreignKey: 'shopId', as: 'shop' });

// Product - NotificationLog (one-to-many)
Product.hasMany(NotificationLog, { foreignKey: 'productId', as: 'notifications', onDelete: 'CASCADE' });
NotificationLog.belongsTo(Product, { foreignKey: 'productId', as: 'product' });

// Shop - NotificationLog (one-to-many)
Shop.hasMany(NotificationLog, { foreignKey: 'shopId', as: 'notifications', onDelete: 'CASCADE' });
NotificationLog.belongsTo(Shop, { foreignKey: 'shopId', as: 'shop' });

// User - NotificationLog (one-to-many)
User.hasMany(NotificationLog, { foreignKey: 'userId', as: 'notifications', onDelete: 'SET NULL' });
NotificationLog.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// User - RefreshToken (one-to-many)
User.hasMany(RefreshToken, { foreignKey: 'userId', as: 'refreshTokens', onDelete: 'CASCADE' });
RefreshToken.belongsTo(User, { foreignKey: 'userId', as: 'user' });

module.exports = {
  User,
  Shop,
  Product,
  CustomField,
  NotificationLog,
  RefreshToken,
};
