const { Product, Shop } = require('../models');
const { Op } = require('sequelize');
const logger = require('../utils/logger');

/**
 * Get all products for a shop with filters
 */
exports.getProducts = async (req, res, next) => {
  try {
    const { shopId } = req;
    const {
      status,
      search,
      expiryFrom,
      expiryTo,
      daysToExpiry,
      sortBy = 'expiryDate',
      order = 'ASC',
      page = 1,
      limit = 20,
    } = req.query;

    // Build where clause
    const where = { shopId };

    if (status) {
      where.status = status;
    }

    if (search) {
      where[Op.or] = [
        { name: { [Op.iLike]: `%${search}%` } },
        { barcode: { [Op.iLike]: `%${search}%` } },
        { description: { [Op.iLike]: `%${search}%` } },
      ];
    }

    if (expiryFrom) {
      where.expiryDate = { ...where.expiryDate, [Op.gte]: expiryFrom };
    }

    if (expiryTo) {
      where.expiryDate = { ...where.expiryDate, [Op.lte]: expiryTo };
    }

    // Calculate expiry date range for daysToExpiry filter
    if (daysToExpiry) {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const targetDate = new Date(today);
      targetDate.setDate(targetDate.getDate() + parseInt(daysToExpiry));

      where.expiryDate = {
        [Op.gte]: today.toISOString().split('T')[0],
        [Op.lte]: targetDate.toISOString().split('T')[0],
      };
    }

    // Pagination
    const offset = (page - 1) * limit;

    // Query products
    const { count, rows: products } = await Product.findAndCountAll({
      where,
      order: [[sortBy, order.toUpperCase()]],
      limit: parseInt(limit),
      offset,
    });

    // Add days to expiry to each product
    const productsWithDays = products.map(product => {
      const productJson = product.toJSON();
      productJson.daysToExpiry = product.getDaysToExpiry();
      return productJson;
    });

    res.json({
      success: true,
      data: {
        products: productsWithDays,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          totalPages: Math.ceil(count / limit),
        },
      },
    });
  } catch (error) {
    logger.error('Get products error:', error);
    next(error);
  }
};

/**
 * Get products expiring soon
 */
exports.getExpiringSoon = async (req, res, next) => {
  try {
    const { shopId } = req;
    const { days = 7 } = req.query;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const targetDate = new Date(today);
    targetDate.setDate(targetDate.getDate() + parseInt(days));

    const products = await Product.findAll({
      where: {
        shopId,
        status: 'active',
        expiryDate: {
          [Op.gte]: today.toISOString().split('T')[0],
          [Op.lte]: targetDate.toISOString().split('T')[0],
        },
      },
      order: [['expiryDate', 'ASC']],
    });

    const productsWithDays = products.map(product => {
      const productJson = product.toJSON();
      productJson.daysToExpiry = product.getDaysToExpiry();
      return productJson;
    });

    res.json({
      success: true,
      data: {
        products: productsWithDays,
        count: products.length,
      },
    });
  } catch (error) {
    logger.error('Get expiring soon error:', error);
    next(error);
  }
};

/**
 * Get expired products
 */
exports.getExpired = async (req, res, next) => {
  try {
    const { shopId } = req;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const products = await Product.findAll({
      where: {
        shopId,
        expiryDate: {
          [Op.lt]: today.toISOString().split('T')[0],
        },
      },
      order: [['expiryDate', 'DESC']],
    });

    const productsWithDays = products.map(product => {
      const productJson = product.toJSON();
      productJson.daysToExpiry = product.getDaysToExpiry();
      return productJson;
    });

    res.json({
      success: true,
      data: {
        products: productsWithDays,
        count: products.length,
      },
    });
  } catch (error) {
    logger.error('Get expired error:', error);
    next(error);
  }
};

/**
 * Get single product by ID
 */
exports.getProduct = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { shopId } = req;

    const product = await Product.findOne({
      where: { id, shopId },
    });

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found',
      });
    }

    const productJson = product.toJSON();
    productJson.daysToExpiry = product.getDaysToExpiry();

    res.json({
      success: true,
      data: {
        product: productJson,
      },
    });
  } catch (error) {
    logger.error('Get product error:', error);
    next(error);
  }
};

/**
 * Create new product
 */
exports.createProduct = async (req, res, next) => {
  try {
    const { shopId } = req;
    const productData = {
      ...req.body,
      shopId,
    };

    const product = await Product.create(productData);

    logger.info(`Product created: ${product.id} by user ${req.userId}`);

    const productJson = product.toJSON();
    productJson.daysToExpiry = product.getDaysToExpiry();

    res.status(201).json({
      success: true,
      message: 'Product created successfully',
      data: {
        product: productJson,
      },
    });
  } catch (error) {
    logger.error('Create product error:', error);
    next(error);
  }
};

/**
 * Update product
 */
exports.updateProduct = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { shopId } = req;

    const product = await Product.findOne({
      where: { id, shopId },
    });

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found',
      });
    }

    await product.update(req.body);

    logger.info(`Product updated: ${id} by user ${req.userId}`);

    const productJson = product.toJSON();
    productJson.daysToExpiry = product.getDaysToExpiry();

    res.json({
      success: true,
      message: 'Product updated successfully',
      data: {
        product: productJson,
      },
    });
  } catch (error) {
    logger.error('Update product error:', error);
    next(error);
  }
};

/**
 * Delete product
 */
exports.deleteProduct = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { shopId } = req;

    const product = await Product.findOne({
      where: { id, shopId },
    });

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found',
      });
    }

    await product.destroy();

    logger.info(`Product deleted: ${id} by user ${req.userId}`);

    res.json({
      success: true,
      message: 'Product deleted successfully',
    });
  } catch (error) {
    logger.error('Delete product error:', error);
    next(error);
  }
};

/**
 * Get dashboard statistics
 */
exports.getDashboardStats = async (req, res, next) => {
  try {
    const { shopId } = req;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Total active products
    const totalActive = await Product.count({
      where: { shopId, status: 'active' },
    });

    // Expired products
    const expired = await Product.count({
      where: {
        shopId,
        expiryDate: { [Op.lt]: today.toISOString().split('T')[0] },
      },
    });

    // Expiring within 7 days
    const sevenDaysFrom = new Date(today);
    sevenDaysFrom.setDate(sevenDaysFrom.getDate() + 7);
    const expiring7Days = await Product.count({
      where: {
        shopId,
        status: 'active',
        expiryDate: {
          [Op.gte]: today.toISOString().split('T')[0],
          [Op.lte]: sevenDaysFrom.toISOString().split('T')[0],
        },
      },
    });

    // Expiring within 3 days (critical)
    const threeDaysFrom = new Date(today);
    threeDaysFrom.setDate(threeDaysFrom.getDate() + 3);
    const expiring3Days = await Product.count({
      where: {
        shopId,
        status: 'active',
        expiryDate: {
          [Op.gte]: today.toISOString().split('T')[0],
          [Op.lte]: threeDaysFrom.toISOString().split('T')[0],
        },
      },
    });

    res.json({
      success: true,
      data: {
        totalActive,
        expired,
        expiring7Days,
        expiring3Days,
      },
    });
  } catch (error) {
    logger.error('Get dashboard stats error:', error);
    next(error);
  }
};
