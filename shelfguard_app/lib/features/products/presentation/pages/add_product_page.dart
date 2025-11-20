import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/services/product_database_service.dart';
import '../../../../core/services/photo_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/product.dart';

class AddProductPage extends StatefulWidget {
  final String? productId;

  const AddProductPage({
    super.key,
    this.productId,
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _barcodeController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedExpiryDate;
  bool _isLoading = false;
  bool _isFetchingProductInfo = false;
  List<String> _photoPaths = [];

  final ProductDatabaseService _productDbService = ProductDatabaseService();
  final PhotoService _photoService = PhotoService();
  final NotificationService _notificationService = NotificationService();

  final List<String> _categoryOptions = [
    'Dairy',
    'Meat & Seafood',
    'Fruits & Vegetables',
    'Bakery',
    'Beverages',
    'Canned Foods',
    'Frozen Foods',
    'Snacks',
    'Condiments',
    'Other',
  ];

  bool get _isEditMode => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadProductData();
    }
  }

  void _loadProductData() {
    // Mock data for edit mode - in production, load from database
    _nameController.text = 'Fresh Milk';
    _categoryController.text = 'Dairy';
    _quantityController.text = '3';
    _barcodeController.text = '123456789012';
    _notesController.text = 'Organic whole milk';
    _selectedExpiryDate = DateTime.now().add(const Duration(days: 7));
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Scan barcode and auto-fill product info
  Future<void> _scanBarcode() async {
    final barcode = await context.push('/products/scan');
    if (barcode != null && barcode is String && mounted) {
      _barcodeController.text = barcode;
      await _fetchProductInfo(barcode);
    }
  }

  /// Fetch product info from Open Food Facts database
  Future<void> _fetchProductInfo(String barcode) async {
    setState(() {
      _isFetchingProductInfo = true;
    });

    try {
      final productInfo = await _productDbService.fetchProductInfo(barcode);

      if (productInfo != null && mounted) {
        // Auto-fill fields
        if (productInfo.name != null && _nameController.text.isEmpty) {
          _nameController.text = productInfo.name!;
        }

        if (productInfo.category != null && _categoryController.text.isEmpty) {
          // Try to match category with our predefined list
          final matchedCategory = _categoryOptions.firstWhere(
            (cat) => cat.toLowerCase().contains(productInfo.category!.toLowerCase()) ||
                productInfo.category!.toLowerCase().contains(cat.toLowerCase()),
            orElse: () => 'Other',
          );
          _categoryController.text = matchedCategory;
        }

        // Suggest expiry date based on category
        if (_selectedExpiryDate == null) {
          final shelfLife = _productDbService.getTypicalShelfLife(productInfo.category);
          if (shelfLife != null) {
            _selectedExpiryDate = DateTime.now().add(Duration(days: shelfLife));
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Product info loaded: ${productInfo.name ?? "Unknown"}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ℹ️ Product not found in database. Please enter manually.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Could not fetch product info. Please enter manually.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingProductInfo = false;
        });
      }
    }
  }

  /// Show photo options dialog
  Future<void> _showPhotoOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, size: 28),
                title: const Text('Take Photo'),
                subtitle: const Text('Use camera'),
                onTap: () async {
                  Navigator.pop(context);
                  await _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, size: 28),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Pick existing photos'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromGallery();
                },
              ),
              if (_photoPaths.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline, size: 28, color: Colors.red),
                  title: const Text('Remove All Photos', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _photoPaths.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All photos removed')),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    if (_photoPaths.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Maximum 5 photos allowed per product'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final photoPath = await _photoService.takePhoto();
    if (photoPath != null && mounted) {
      setState(() {
        _photoPaths.add(photoPath);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📸 Photo added'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    final remainingSlots = 5 - _photoPaths.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Maximum 5 photos allowed per product'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final photos = await _photoService.pickMultipleFromGallery(maxImages: remainingSlots);
    if (photos.isNotEmpty && mounted) {
      setState(() {
        _photoPaths.addAll(photos);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📸 ${photos.length} photo(s) added'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoPaths.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo removed'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      helpText: 'Select Expiry Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please fill in all required fields'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please select an expiry date'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create product
      final product = Product(
        id: _isEditMode ? widget.productId! : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        expiryDate: _selectedExpiryDate!,
        quantity: int.parse(_quantityController.text),
        barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        photos: _photoPaths.isEmpty ? null : _photoPaths,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: Save to database (Hive or your backend)
      await Future.delayed(const Duration(seconds: 1)); // Simulating save

      // Schedule notifications for expiry alerts
      await _notificationService.scheduleAllNotificationsForProduct(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? '✅ Product updated successfully!'
                  : '✅ Product added successfully! Notifications scheduled.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Navigate to product detail
              },
            ),
          ),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Add Product'),
        actions: [
          if (_photoPaths.isNotEmpty || _barcodeController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Product Info'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_barcodeController.text.isNotEmpty)
                          Text('Barcode: ${_barcodeController.text}'),
                        if (_photoPaths.isNotEmpty)
                          Text('Photos: ${_photoPaths.length}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barcode scan section (at top for better UX)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.withOpacity(0.5),
                      theme.colorScheme.primaryContainer.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.qr_code_scanner,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Add',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Scan barcode for instant product info',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: _isFetchingProductInfo ? 'Fetching info...' : 'Scan Barcode',
                      onPressed: _scanBarcode,
                      icon: Icons.qr_code_scanner,
                      height: 48,
                      isLoading: _isFetchingProductInfo,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Product name
              CustomTextField(
                label: 'Product Name *',
                hint: 'e.g., Fresh Milk',
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                prefixIcon: Icons.shopping_bag_outlined,
                validator: Validators.validateProductName,
              ),
              const SizedBox(height: 20),

              // Category with dropdown
              GestureDetector(
                onTap: _showCategoryPicker,
                child: AbsorbPointer(
                  child: CustomTextField(
                    label: 'Category *',
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
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expiry Date *',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedExpiryDate == null
                                  ? 'Tap to select date'
                                  : DateFormat('EEEE, MMMM d, yyyy')
                                      .format(_selectedExpiryDate!),
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
                label: 'Quantity *',
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
                onSuffixIconTap: _scanBarcode,
              ),
              const SizedBox(height: 20),

              // Photos section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.photo_camera,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product Photos',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_photoPaths.length}/5 photos added',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_photoPaths.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _photoPaths.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_photoPaths[index]),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removePhoto(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    CustomButton(
                      text: _photoPaths.isEmpty ? 'Add Photos' : 'Add More Photos',
                      onPressed: _showPhotoOptions,
                      icon: Icons.add_photo_alternate,
                      height: 48,
                      variant: ButtonVariant.outlined,
                    ),
                  ],
                ),
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
              const SizedBox(height: 16),

              // Helper text
              Text(
                '* Required fields',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.category,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Category',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categoryOptions.length,
                  itemBuilder: (context, index) {
                    final category = _categoryOptions[index];
                    final isSelected = _categoryController.text == category;

                    return ListTile(
                      title: Text(category),
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      selected: isSelected,
                      selectedTileColor:
                          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
}
