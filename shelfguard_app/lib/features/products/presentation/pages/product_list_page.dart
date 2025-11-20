import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/product.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/empty_state.dart';

enum ProductFilter { all, expired, critical, expiringSoon, safe }
enum ProductSort { nameAsc, nameDesc, expiryAsc, expiryDesc }

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  ProductFilter _currentFilter = ProductFilter.all;
  ProductSort _currentSort = ProductSort.expiryAsc;
  String _searchQuery = '';

  // Mock products for demo
  final List<Product> _mockProducts = [
    Product(
      id: '1',
      name: 'Fresh Milk',
      category: 'Dairy',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      quantity: 3,
      barcode: '123456789',
      notes: 'Organic whole milk',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '2',
      name: 'Organic Eggs',
      category: 'Dairy',
      expiryDate: DateTime.now().add(const Duration(days: 5)),
      quantity: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '3',
      name: 'Whole Wheat Bread',
      category: 'Bakery',
      expiryDate: DateTime.now().add(const Duration(days: 1)),
      quantity: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '4',
      name: 'Greek Yogurt',
      category: 'Dairy',
      expiryDate: DateTime.now().add(const Duration(days: 10)),
      quantity: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '5',
      name: 'Chicken Breast',
      category: 'Meat',
      expiryDate: DateTime.now().subtract(const Duration(days: 1)),
      quantity: 2,
      notes: 'Fresh from local farm',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '6',
      name: 'Cheddar Cheese',
      category: 'Dairy',
      expiryDate: DateTime.now().add(const Duration(days: 15)),
      quantity: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '7',
      name: 'Fresh Salmon',
      category: 'Seafood',
      expiryDate: DateTime.now().add(const Duration(days: 3)),
      quantity: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '8',
      name: 'Baby Spinach',
      category: 'Vegetables',
      expiryDate: DateTime.now().add(const Duration(days: 4)),
      quantity: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  List<Product> get _filteredProducts {
    var products = _mockProducts.where((product) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return product.name.toLowerCase().contains(query) ||
               product.category.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    // Status filter
    switch (_currentFilter) {
      case ProductFilter.expired:
        products = products.where((p) => p.isExpired).toList();
        break;
      case ProductFilter.critical:
        products = products.where((p) => p.isCritical && !p.isExpired).toList();
        break;
      case ProductFilter.expiringSoon:
        products = products.where((p) => p.isExpiringSoon && !p.isCritical && !p.isExpired).toList();
        break;
      case ProductFilter.safe:
        products = products.where((p) => !p.isExpired && !p.isExpiringSoon).toList();
        break;
      case ProductFilter.all:
        break;
    }

    // Sort
    switch (_currentSort) {
      case ProductSort.nameAsc:
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProductSort.nameDesc:
        products.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ProductSort.expiryAsc:
        products.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
        break;
      case ProductSort.expiryDesc:
        products.sort((a, b) => b.expiryDate.compareTo(a.expiryDate));
        break;
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredProducts = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', ProductFilter.all, null),
                const SizedBox(width: 8),
                _buildFilterChip('Expired', ProductFilter.expired, theme.colorScheme.error),
                const SizedBox(width: 8),
                _buildFilterChip('Critical', ProductFilter.critical, const Color(0xFFF44336)),
                const SizedBox(width: 8),
                _buildFilterChip('Expiring Soon', ProductFilter.expiringSoon, const Color(0xFFFF9800)),
                const SizedBox(width: 8),
                _buildFilterChip('Safe', ProductFilter.safe, const Color(0xFF4CAF50)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Product list
          Expanded(
            child: filteredProducts.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'No Products Found',
                    message: _searchQuery.isNotEmpty
                        ? 'Try adjusting your search or filters'
                        : 'Start by adding your first product',
                    actionLabel: 'Add Product',
                    onAction: () => context.push('/products/add'),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            context.push('/products/${product.id}');
                          },
                          onLongPress: () {
                            _showProductOptions(product);
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              // Already on products
              break;
            case 2:
              context.push('/products/scan');
              break;
            case 3:
              context.push('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/products/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildFilterChip(String label, ProductFilter filter, Color? color) {
    final isSelected = _currentFilter == filter;
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _currentFilter = filter;
        });
      },
      backgroundColor: color?.withOpacity(0.1),
      selectedColor: color ?? theme.colorScheme.primaryContainer,
      checkmarkColor: color ?? theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? (color ?? theme.colorScheme.onPrimaryContainer)
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  void _showFilterSheet() {
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
                'Filter Products',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('All Products'),
                leading: Radio<ProductFilter>(
                  value: ProductFilter.all,
                  groupValue: _currentFilter,
                  onChanged: (value) {
                    setState(() {
                      _currentFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _currentFilter = ProductFilter.all;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Expired'),
                leading: Radio<ProductFilter>(
                  value: ProductFilter.expired,
                  groupValue: _currentFilter,
                  onChanged: (value) {
                    setState(() {
                      _currentFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _currentFilter = ProductFilter.expired;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Critical (≤3 days)'),
                leading: Radio<ProductFilter>(
                  value: ProductFilter.critical,
                  groupValue: _currentFilter,
                  onChanged: (value) {
                    setState(() {
                      _currentFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _currentFilter = ProductFilter.critical;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Expiring Soon (≤7 days)'),
                leading: Radio<ProductFilter>(
                  value: ProductFilter.expiringSoon,
                  groupValue: _currentFilter,
                  onChanged: (value) {
                    setState(() {
                      _currentFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _currentFilter = ProductFilter.expiringSoon;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Safe (>7 days)'),
                leading: Radio<ProductFilter>(
                  value: ProductFilter.safe,
                  groupValue: _currentFilter,
                  onChanged: (value) {
                    setState(() {
                      _currentFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _currentFilter = ProductFilter.safe;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortSheet() {
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
                'Sort Products',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Name (A-Z)'),
                leading: Radio<ProductSort>(
                  value: ProductSort.nameAsc,
                  groupValue: _currentSort,
                  onChanged: (value) {
                    setState(() {
                      _currentSort = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _currentSort = ProductSort.nameAsc;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Name (Z-A)'),
                leading: Radio<ProductSort>(
                  value: ProductSort.nameDesc,
                  groupValue: _currentSort,
                  onChanged: (value) {
                    setState(() {
                      _currentSort = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _currentSort = ProductSort.nameDesc;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Expiry Date (Earliest First)'),
                leading: Radio<ProductSort>(
                  value: ProductSort.expiryAsc,
                  groupValue: _currentSort,
                  onChanged: (value) {
                    setState(() {
                      _currentSort = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _currentSort = ProductSort.expiryAsc;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Expiry Date (Latest First)'),
                leading: Radio<ProductSort>(
                  value: ProductSort.expiryDesc,
                  groupValue: _currentSort,
                  onChanged: (value) {
                    setState(() {
                      _currentSort = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _currentSort = ProductSort.expiryDesc;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProductOptions(Product product) {
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
                product.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/products/${product.id}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Product'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/products/${product.id}/edit');
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                title: Text('Delete Product', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(product);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} deleted')),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
