const { Shop, CustomField } = require('../models');
const logger = require('../utils/logger');

/**
 * Get shop settings
 */
exports.getShopSettings = async (req, res, next) => {
  try {
    const { shopId } = req;

    const shop = await Shop.findByPk(shopId);

    if (!shop) {
      return res.status(404).json({
        success: false,
        message: 'Shop not found',
      });
    }

    res.json({
      success: true,
      data: {
        shop,
      },
    });
  } catch (error) {
    logger.error('Get shop settings error:', error);
    next(error);
  }
};

/**
 * Update shop settings
 */
exports.updateShopSettings = async (req, res, next) => {
  try {
    const { shopId } = req;

    const shop = await Shop.findByPk(shopId);

    if (!shop) {
      return res.status(404).json({
        success: false,
        message: 'Shop not found',
      });
    }

    await shop.update(req.body);

    logger.info(`Shop settings updated: ${shopId} by user ${req.userId}`);

    res.json({
      success: true,
      message: 'Shop settings updated successfully',
      data: {
        shop,
      },
    });
  } catch (error) {
    logger.error('Update shop settings error:', error);
    next(error);
  }
};

/**
 * Get all custom fields for a shop
 */
exports.getCustomFields = async (req, res, next) => {
  try {
    const { shopId } = req;

    const customFields = await CustomField.findAll({
      where: { shopId },
      order: [['sortOrder', 'ASC']],
    });

    res.json({
      success: true,
      data: {
        customFields,
        count: customFields.length,
      },
    });
  } catch (error) {
    logger.error('Get custom fields error:', error);
    next(error);
  }
};

/**
 * Create custom field
 */
exports.createCustomField = async (req, res, next) => {
  try {
    const { shopId } = req;
    const fieldData = {
      ...req.body,
      shopId,
    };

    const customField = await CustomField.create(fieldData);

    logger.info(`Custom field created: ${customField.id} by user ${req.userId}`);

    res.status(201).json({
      success: true,
      message: 'Custom field created successfully',
      data: {
        customField,
      },
    });
  } catch (error) {
    logger.error('Create custom field error:', error);
    next(error);
  }
};

/**
 * Update custom field
 */
exports.updateCustomField = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { shopId } = req;

    const customField = await CustomField.findOne({
      where: { id, shopId },
    });

    if (!customField) {
      return res.status(404).json({
        success: false,
        message: 'Custom field not found',
      });
    }

    await customField.update(req.body);

    logger.info(`Custom field updated: ${id} by user ${req.userId}`);

    res.json({
      success: true,
      message: 'Custom field updated successfully',
      data: {
        customField,
      },
    });
  } catch (error) {
    logger.error('Update custom field error:', error);
    next(error);
  }
};

/**
 * Delete custom field
 */
exports.deleteCustomField = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { shopId } = req;

    const customField = await CustomField.findOne({
      where: { id, shopId },
    });

    if (!customField) {
      return res.status(404).json({
        success: false,
        message: 'Custom field not found',
      });
    }

    await customField.destroy();

    logger.info(`Custom field deleted: ${id} by user ${req.userId}`);

    res.json({
      success: true,
      message: 'Custom field deleted successfully',
    });
  } catch (error) {
    logger.error('Delete custom field error:', error);
    next(error);
  }
};
