import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../products/domain/entities/product.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/empty_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Mock products for demo
  final List<Product> _mockProducts = [
    Product(
      id: '1',
      name: 'Fresh Milk',
      category: 'Dairy',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      quantity: 3,
      barcode: '123456789',
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  int get _totalProducts => _mockProducts.length;
  int get _expiredCount => _mockProducts.where((p) => p.isExpired).length;
  int get _criticalCount => _mockProducts.where((p) => p.isCritical && !p.isExpired).length;
  int get _expiringSoonCount => _mockProducts.where((p) => p.isExpiringSoon && !p.isCritical && !p.isExpired).length;

  List<Product> get _urgentProducts {
    final urgent = _mockProducts.where((p) => p.isExpired || p.isCritical).toList();
    urgent.sort((a, b) => a.daysToExpiry.compareTo(b.daysToExpiry));
    return urgent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') {
                context.push('/settings');
              } else if (value == 'logout') {
                context.read<AuthBloc>().add(LogoutRequested());
                context.go('/login');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_outlined),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Text(
                  'Welcome back!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    StatCard(
                      title: 'Total Products',
                      value: '$_totalProducts',
                      icon: Icons.inventory_2_outlined,
                      color: theme.colorScheme.primary,
                      onTap: () => context.push('/products'),
                    ),
                    StatCard(
                      title: 'Expired',
                      value: '$_expiredCount',
                      icon: Icons.error_outline,
                      color: theme.colorScheme.error,
                      onTap: () => context.push('/products'),
                    ),
                    StatCard(
                      title: 'Critical',
                      value: '$_criticalCount',
                      icon: Icons.warning_amber_outlined,
                      color: const Color(0xFFF44336),
                      subtitle: '≤3 days',
                      onTap: () => context.push('/products'),
                    ),
                    StatCard(
                      title: 'Expiring Soon',
                      value: '$_expiringSoonCount',
                      icon: Icons.schedule_outlined,
                      color: const Color(0xFFFF9800),
                      subtitle: '≤7 days',
                      onTap: () => context.push('/products'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Urgent products section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Urgent Products',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/products'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_urgentProducts.isEmpty)
                  const EmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'All Good!',
                    message: 'No urgent products at the moment',
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _urgentProducts.length > 3 ? 3 : _urgentProducts.length,
                    itemBuilder: (context, index) {
                      final product = _urgentProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          context.push('/products/${product.id}');
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              context.push('/products');
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
}
