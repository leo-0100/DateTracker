import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/open_food_facts_service.dart';
import '../../../analytics/data/services/analytics_service.dart';

class AddProductPageEnhanced extends StatefulWidget {
  final String? productId;
  final String? scannedBarcode;

  const AddProductPageEnhanced({
    super.key,
    this.productId,
    this.scannedBarcode,
  });

  @override
  State<AddProductPageEnhanced> createState() => _AddProductPageEnhancedState();
}

class _AddProductPageEnhancedState extends State<AddProductPageEnhanced> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _storageLocationController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _barcodeController = TextEditingController();
  final _notesController = TextEditingController();

  final _notificationService = NotificationService();
  final _analyticsService = AnalyticsService();
  final _openFoodFactsService = OpenFoodFactsService();

  DateTime? _selectedExpiryDate;
  bool _isLoading = false;
  bool _isFetchingProductInfo = false;

  final List<String> _categoryOptions = [
    'Dairy',
    'Meat',
    'Seafood',
    'Vegetables',
    'Fruits',
    'Bakery',
    'Beverages',
    'Canned',
    'Frozen',
    'Grains',
    'Condiments',
    'Snacks',
    'Other',
  ];

  final List<String> _storageLocationOptions = [
    'Refrigerator',
    'Freezer',
    'Pantry',
    'Cabinet',
    'Counter',
    'Garage',
    'Cellar',
    'Other',
  ];

  bool get _isEditMode => widget.productId != null;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();

    if (widget.scannedBarcode != null) {
      _barcodeController.text = widget.scannedBarcode!;
      _fetchProductInfoFromBarcode(widget.scannedBarcode!);
    }

    if (_isEditMode) {
      _loadProductData();
    }
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  Future<void> _fetchProductInfoFromBarcode(String barcode) async {
    setState(() => _isFetchingProductInfo = true);

    try {
      final productInfo = await _openFoodFactsService.getProductByBarcode(barcode);

      if (productInfo != null && productInfo.isValid) {
        setState(() {
          if (productInfo.name != null && _nameController.text.isEmpty) {
            _nameController.text = productInfo.name!;
          }
          if (productInfo.category != null && _categoryController.text.isEmpty) {
            _categoryController.text = productInfo.category!;
          }

          // Set suggested expiry date based on category
          if (productInfo.category != null && _selectedExpiryDate == null) {
            final shelfLifeDays = OpenFoodFactsService.getTypicalShelfLifeDays(
              productInfo.category!,
            );
            if (shelfLifeDays != null) {
              _selectedExpiryDate = DateTime.now().add(Duration(days: shelfLifeDays));
            }
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product info loaded: ${productInfo.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found in database. Please enter manually.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error fetching product info'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isFetchingProductInfo = false);
    }
  }

  void _loadProductData() {
    // TODO: Load actual product data from database
    _nameController.text = 'Fresh Milk';
    _categoryController.text = 'Dairy';
    _storageLocationController.text = 'Refrigerator';
    _quantityController.text = '3';
    _barcodeController.text = '123456789012';
    _notesController.text = 'Organic whole milk';
    _selectedExpiryDate = DateTime.now().add(const Duration(days: 2));
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _storageLocationController.dispose();
    _quantityController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an expiry date')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Save product to database with storageLocation field
      final productId = widget.productId ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Schedule notifications for the product
      await _notificationService.scheduleProductExpiryNotifications(
        productId: productId,
        productName: _nameController.text,
        expiryDate: _selectedExpiryDate!,
      );

      // Update analytics - increment products added
      await _analyticsService.incrementProductsAdded();

      // If barcode was used, increment scan count
      if (_barcodeController.text.isNotEmpty) {
        await _analyticsService.incrementScans();
      }

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Product updated successfully' : 'Product added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Add Product'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product name
                  CustomTextField(
                    label: 'Product Name',
                    hint: 'e.g., Fresh Milk',
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: Icons.shopping_bag_outlined,
                    validator: Validators.validateProductName,
                  ),
                  const SizedBox(height: 20),

                  // Category with dropdown
                  GestureDetector(
                    onTap: () => _showCategoryPicker(),
                    child: AbsorbPointer(
                      child: CustomTextField(
                        label: 'Category',
                        hint: 'Select category',
                        controller: _categoryController,
                        prefixIcon: Icons.category_outlined,
                        suffixIcon: Icons.arrow_drop_down,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Storage Location with dropdown
                  GestureDetector(
                    onTap: () => _showStorageLocationPicker(),
                    child: AbsorbPointer(
                      child: CustomTextField(
                        label: 'Storage Location',
                        hint: 'Select storage location',
                        controller: _storageLocationController,
                        prefixIcon: Icons.kitchen_outlined,
                        suffixIcon: Icons.arrow_drop_down,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a storage location';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Expiry date picker
                  GestureDetector(
                    onTap: _selectExpiryDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedExpiryDate == null
                              ? theme.colorScheme.error
                              : theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expiry Date',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedExpiryDate == null
                                      ? 'Select expiry date'
                                      : DateFormat('EEEE, MMMM d, yyyy').format(_selectedExpiryDate!),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _selectedExpiryDate == null
                                        ? theme.colorScheme.onSurface.withOpacity(0.4)
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedExpiryDate == null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: Text(
                        'Please select an expiry date',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Quantity
                  CustomTextField(
                    label: 'Quantity',
                    hint: 'Enter quantity (1-10,000)',
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.numbers,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: Validators.validateQuantity,
                  ),
                  const SizedBox(height: 20),

                  // Barcode (optional)
                  CustomTextField(
                    label: 'Barcode (Optional)',
                    hint: 'Scan or enter barcode',
                    controller: _barcodeController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.qr_code,
                    suffixIcon: Icons.qr_code_scanner,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        return Validators.validateBarcode(value);
                      }
                      return null;
                    },
                    onSuffixIconTap: () {
                      context.push('/products/scan').then((barcode) {
                        if (barcode != null && barcode is String) {
                          _barcodeController.text = barcode;
                          _fetchProductInfoFromBarcode(barcode);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Notes (optional)
                  CustomTextField(
                    label: 'Notes (Optional)',
                    hint: 'Add any additional notes (max 500 chars)',
                    controller: _notesController,
                    maxLines: 4,
                    prefixIcon: Icons.note_outlined,
                    validator: Validators.validateNotes,
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  CustomButton(
                    text: _isEditMode ? 'Update Product' : 'Add Product',
                    onPressed: _saveProduct,
                    isLoading: _isLoading,
                    icon: _isEditMode ? Icons.check : Icons.add,
                  ),
                ],
              ),
            ),
          ),
          if (_isFetchingProductInfo)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Fetching product info...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Category',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categoryOptions.length,
                  itemBuilder: (context, index) {
                    final category = _categoryOptions[index];
                    return ListTile(
                      title: Text(category),
                      leading: Radio<String>(
                        value: category,
                        groupValue: _categoryController.text,
                        onChanged: (value) {
                          setState(() {
                            _categoryController.text = value!;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _categoryController.text = category;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStorageLocationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Storage Location',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _storageLocationOptions.length,
                  itemBuilder: (context, index) {
                    final location = _storageLocationOptions[index];
                    IconData icon;
                    switch (location) {
                      case 'Refrigerator':
                        icon = Icons.kitchen;
                        break;
                      case 'Freezer':
                        icon = Icons.ac_unit;
                        break;
                      case 'Pantry':
                        icon = Icons.shelves;
                        break;
                      case 'Cabinet':
                        icon = Icons.kitchen_outlined;
                        break;
                      case 'Counter':
                        icon = Icons.countertops;
                        break;
                      default:
                        icon = Icons.location_on;
                    }

                    return ListTile(
                      leading: Icon(icon),
                      title: Text(location),
                      trailing: Radio<String>(
                        value: location,
                        groupValue: _storageLocationController.text,
                        onChanged: (value) {
                          setState(() {
                            _storageLocationController.text = value!;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _storageLocationController.text = location;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
