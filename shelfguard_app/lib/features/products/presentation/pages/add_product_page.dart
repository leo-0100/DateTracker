import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

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
    'Other',
  ];

  bool get _isEditMode => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      // TODO: Load product data
      _loadProductData();
    }
  }

  void _loadProductData() {
    // Mock data for edit mode
    _nameController.text = 'Fresh Milk';
    _categoryController.text = 'Dairy';
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

    // TODO: Save product to database
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
        ),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Add Product'),
      ),
      body: Form(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
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
                hint: 'Enter quantity',
                controller: _quantityController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.numbers,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity < 1) {
                    return 'Quantity must be at least 1';
                  }
                  return null;
                },
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
                onSuffixIconTap: () {
                  context.push('/products/scan').then((barcode) {
                    if (barcode != null && barcode is String) {
                      _barcodeController.text = barcode;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              // Notes (optional)
              CustomTextField(
                label: 'Notes (Optional)',
                hint: 'Add any additional notes',
                controller: _notesController,
                maxLines: 4,
                prefixIcon: Icons.note_outlined,
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
}
