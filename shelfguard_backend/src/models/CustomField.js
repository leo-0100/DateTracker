const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const CustomField = sequelize.define('CustomField', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  shopId: {
    type: DataTypes.UUID,
    allowNull: false,
    field: 'shop_id',
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  fieldType: {
    type: DataTypes.STRING,
    allowNull: false,
    field: 'field_type',
    validate: {
      isIn: [['text', 'number', 'date', 'boolean', 'select']],
    },
  },
  required: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: false,
  },
  selectOptions: {
    type: DataTypes.ARRAY(DataTypes.TEXT),
    field: 'select_options',
  },
  defaultValue: {
    type: DataTypes.TEXT,
    field: 'default_value',
  },
  sortOrder: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    field: 'sort_order',
  },
}, {
  tableName: 'custom_fields',
  underscored: true,
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [
    {
      unique: true,
      fields: ['shop_id', 'name'],
    },
  ],
});

module.exports = CustomField;
