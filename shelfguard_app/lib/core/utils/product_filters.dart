import '../../features/products/domain/entities/product.dart';

/// Filter criteria for products
enum ProductStatus {
  all,
  expired,
  expiringSoon, // Within 3 days
  fresh, // More than 3 days
}

enum SortOption {
  expiryDateAsc, // Soonest first
  expiryDateDesc, // Latest first
  nameAsc,
  nameDesc,
  dateAddedDesc, // Newest first
  dateAddedAsc, // Oldest first
  quantityAsc,
  quantityDesc,
}

/// Utility class for filtering and sorting products
class ProductFilters {
  /// Filter products by search query
  static List<Product> searchProducts(
    List<Product> products,
    String query,
  ) {
    if (query.isEmpty) return products;

    final lowerQuery = query.toLowerCase();

    return products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.category.toLowerCase().contains(lowerQuery) ||
          (product.barcode?.toLowerCase().contains(lowerQuery) ?? false) ||
          (product.notes?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Filter products by status
  static List<Product> filterByStatus(
    List<Product> products,
    ProductStatus status,
  ) {
    switch (status) {
      case ProductStatus.all:
        return products;

      case ProductStatus.expired:
        return products.where((p) => p.isExpired).toList();

      case ProductStatus.expiringSoon:
        return products
            .where((p) => !p.isExpired && p.daysToExpiry <= 3)
            .toList();

      case ProductStatus.fresh:
        return products.where((p) => p.daysToExpiry > 3).toList();
    }
  }

  /// Filter products by category
  static List<Product> filterByCategory(
    List<Product> products,
    String category,
  ) {
    if (category == 'All') return products;
    return products.where((p) => p.category == category).toList();
  }

  /// Filter products by multiple categories
  static List<Product> filterByCategories(
    List<Product> products,
    Set<String> categories,
  ) {
    if (categories.isEmpty) return products;
    return products.where((p) => categories.contains(p.category)).toList();
  }

  /// Sort products
  static List<Product> sortProducts(
    List<Product> products,
    SortOption sortOption,
  ) {
    final sortedList = List<Product>.from(products);

    switch (sortOption) {
      case SortOption.expiryDateAsc:
        sortedList.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
        break;

      case SortOption.expiryDateDesc:
        sortedList.sort((a, b) => b.expiryDate.compareTo(a.expiryDate));
        break;

      case SortOption.nameAsc:
        sortedList.sort((a, b) => a.name.compareTo(b.name));
        break;

      case SortOption.nameDesc:
        sortedList.sort((a, b) => b.name.compareTo(a.name));
        break;

      case SortOption.dateAddedDesc:
        sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case SortOption.dateAddedAsc:
        sortedList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;

      case SortOption.quantityAsc:
        sortedList.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;

      case SortOption.quantityDesc:
        sortedList.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
    }

    return sortedList;
  }

  /// Get all unique categories from products
  static Set<String> getCategories(List<Product> products) {
    return products.map((p) => p.category).toSet();
  }

  /// Get product counts by status
  static Map<ProductStatus, int> getStatusCounts(List<Product> products) {
    return {
      ProductStatus.all: products.length,
      ProductStatus.expired:
          products.where((p) => p.isExpired).length,
      ProductStatus.expiringSoon:
          products.where((p) => !p.isExpired && p.daysToExpiry <= 3).length,
      ProductStatus.fresh:
          products.where((p) => p.daysToExpiry > 3).length,
    };
  }

  /// Get product counts by category
  static Map<String, int> getCategoryCounts(List<Product> products) {
    final counts = <String, int>{};
    for (final product in products) {
      counts[product.category] = (counts[product.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Complex filter with multiple criteria
  static List<Product> applyFilters({
    required List<Product> products,
    String? searchQuery,
    ProductStatus? status,
    Set<String>? categories,
    SortOption? sortOption,
  }) {
    var filtered = products;

    // Apply search
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = searchProducts(filtered, searchQuery);
    }

    // Apply status filter
    if (status != null) {
      filtered = filterByStatus(filtered, status);
    }

    // Apply category filter
    if (categories != null && categories.isNotEmpty) {
      filtered = filterByCategories(filtered, categories);
    }

    // Apply sorting
    if (sortOption != null) {
      filtered = sortProducts(filtered, sortOption);
    }

    return filtered;
  }

  /// Get sort option display name
  static String getSortOptionName(SortOption option) {
    switch (option) {
      case SortOption.expiryDateAsc:
        return 'Expiry Date (Soonest)';
      case SortOption.expiryDateDesc:
        return 'Expiry Date (Latest)';
      case SortOption.nameAsc:
        return 'Name (A-Z)';
      case SortOption.nameDesc:
        return 'Name (Z-A)';
      case SortOption.dateAddedDesc:
        return 'Date Added (Newest)';
      case SortOption.dateAddedAsc:
        return 'Date Added (Oldest)';
      case SortOption.quantityAsc:
        return 'Quantity (Low to High)';
      case SortOption.quantityDesc:
        return 'Quantity (High to Low)';
    }
  }

  /// Get status display name
  static String getStatusName(ProductStatus status) {
    switch (status) {
      case ProductStatus.all:
        return 'All Products';
      case ProductStatus.expired:
        return 'Expired';
      case ProductStatus.expiringSoon:
        return 'Expiring Soon';
      case ProductStatus.fresh:
        return 'Fresh';
    }
  }
}
