import '../../features/products/domain/entities/product.dart';

/// Batch operation types
enum BatchOperationType {
  delete,
  updateCategory,
  updateExpiryDate,
  updateQuantity,
  markAsConsumed,
  markAsWasted,
  export,
}

/// Batch operation result
class BatchOperationResult {
  final int successCount;
  final int failureCount;
  final List<String> errors;
  final bool isSuccess;

  BatchOperationResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
  }) : isSuccess = failureCount == 0;

  String get summary {
    if (isSuccess) {
      return '✅ Successfully processed $successCount item(s)';
    } else {
      return '⚠️ Processed $successCount item(s), $failureCount failed';
    }
  }
}

/// Utility class for batch operations on products
class BatchOperations {
  /// Delete multiple products
  static Future<BatchOperationResult> deleteProducts(
    List<Product> products,
    Future<bool> Function(Product) deleteFunction,
  ) async {
    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];

    for (final product in products) {
      try {
        final success = await deleteFunction(product);
        if (success) {
          successCount++;
        } else {
          failureCount++;
          errors.add('Failed to delete: ${product.name}');
        }
      } catch (e) {
        failureCount++;
        errors.add('Error deleting ${product.name}: $e');
      }
    }

    return BatchOperationResult(
      successCount: successCount,
      failureCount: failureCount,
      errors: errors,
    );
  }

  /// Update category for multiple products
  static Future<BatchOperationResult> updateCategory(
    List<Product> products,
    String newCategory,
    Future<bool> Function(Product, String) updateFunction,
  ) async {
    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];

    for (final product in products) {
      try {
        final success = await updateFunction(product, newCategory);
        if (success) {
          successCount++;
        } else {
          failureCount++;
          errors.add('Failed to update: ${product.name}');
        }
      } catch (e) {
        failureCount++;
        errors.add('Error updating ${product.name}: $e');
      }
    }

    return BatchOperationResult(
      successCount: successCount,
      failureCount: failureCount,
      errors: errors,
    );
  }

  /// Extend expiry date for multiple products
  static Future<BatchOperationResult> extendExpiryDate(
    List<Product> products,
    int daysToAdd,
    Future<bool> Function(Product, DateTime) updateFunction,
  ) async {
    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];

    for (final product in products) {
      try {
        final newExpiryDate =
            product.expiryDate.add(Duration(days: daysToAdd));
        final success = await updateFunction(product, newExpiryDate);
        if (success) {
          successCount++;
        } else {
          failureCount++;
          errors.add('Failed to update: ${product.name}');
        }
      } catch (e) {
        failureCount++;
        errors.add('Error updating ${product.name}: $e');
      }
    }

    return BatchOperationResult(
      successCount: successCount,
      failureCount: failureCount,
      errors: errors,
    );
  }

  /// Update quantity for multiple products
  static Future<BatchOperationResult> updateQuantity(
    List<Product> products,
    int Function(Product) quantityCalculator,
    Future<bool> Function(Product, int) updateFunction,
  ) async {
    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];

    for (final product in products) {
      try {
        final newQuantity = quantityCalculator(product);
        if (newQuantity < 0) {
          failureCount++;
          errors.add('Invalid quantity for ${product.name}');
          continue;
        }

        final success = await updateFunction(product, newQuantity);
        if (success) {
          successCount++;
        } else {
          failureCount++;
          errors.add('Failed to update: ${product.name}');
        }
      } catch (e) {
        failureCount++;
        errors.add('Error updating ${product.name}: $e');
      }
    }

    return BatchOperationResult(
      successCount: successCount,
      failureCount: failureCount,
      errors: errors,
    );
  }

  /// Mark multiple products as consumed
  static Future<BatchOperationResult> markAsConsumed(
    List<Product> products,
    Future<bool> Function(Product) markFunction,
  ) async {
    return await deleteProducts(products, markFunction);
  }

  /// Mark multiple products as wasted
  static Future<BatchOperationResult> markAsWasted(
    List<Product> products,
    Future<bool> Function(Product) markFunction,
  ) async {
    return await deleteProducts(products, markFunction);
  }

  /// Export products to CSV
  static String exportToCSV(List<Product> products) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
        'ID,Name,Category,Expiry Date,Days to Expiry,Quantity,Barcode,Notes,Created At');

    // Data rows
    for (final product in products) {
      buffer.writeln([
        product.id,
        _escapeCsv(product.name),
        _escapeCsv(product.category),
        product.expiryDate.toIso8601String().split('T')[0],
        product.daysToExpiry,
        product.quantity,
        product.barcode ?? '',
        _escapeCsv(product.notes ?? ''),
        product.createdAt.toIso8601String(),
      ].join(','));
    }

    return buffer.toString();
  }

  /// Export products to JSON
  static String exportToJSON(List<Product> products) {
    final jsonList = products
        .map((p) => {
              'id': p.id,
              'name': p.name,
              'category': p.category,
              'expiryDate': p.expiryDate.toIso8601String(),
              'daysToExpiry': p.daysToExpiry,
              'quantity': p.quantity,
              'barcode': p.barcode,
              'notes': p.notes,
              'createdAt': p.createdAt.toIso8601String(),
            })
        .toList();

    return jsonList.toString();
  }

  /// Escape CSV values
  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Get quick actions for batch operations
  static List<String> getQuickActions() {
    return [
      'Delete Selected',
      'Change Category',
      'Extend Expiry (+7 days)',
      'Mark as Consumed',
      'Mark as Wasted',
      'Export to CSV',
    ];
  }

  /// Validate batch operation
  static String? validateBatchOperation(
    BatchOperationType operation,
    List<Product> products,
  ) {
    if (products.isEmpty) {
      return 'No products selected';
    }

    switch (operation) {
      case BatchOperationType.delete:
        return null;

      case BatchOperationType.updateCategory:
        return null;

      case BatchOperationType.updateExpiryDate:
        return null;

      case BatchOperationType.updateQuantity:
        return null;

      case BatchOperationType.markAsConsumed:
      case BatchOperationType.markAsWasted:
        return null;

      case BatchOperationType.export:
        if (products.length > 1000) {
          return 'Too many products to export (max: 1000)';
        }
        return null;
    }
  }

  /// Get operation display name
  static String getOperationName(BatchOperationType operation) {
    switch (operation) {
      case BatchOperationType.delete:
        return 'Delete Products';
      case BatchOperationType.updateCategory:
        return 'Update Category';
      case BatchOperationType.updateExpiryDate:
        return 'Update Expiry Date';
      case BatchOperationType.updateQuantity:
        return 'Update Quantity';
      case BatchOperationType.markAsConsumed:
        return 'Mark as Consumed';
      case BatchOperationType.markAsWasted:
        return 'Mark as Wasted';
      case BatchOperationType.export:
        return 'Export Products';
    }
  }

  /// Get operation icon
  static String getOperationIcon(BatchOperationType operation) {
    switch (operation) {
      case BatchOperationType.delete:
        return '🗑️';
      case BatchOperationType.updateCategory:
        return '📁';
      case BatchOperationType.updateExpiryDate:
        return '📅';
      case BatchOperationType.updateQuantity:
        return '🔢';
      case BatchOperationType.markAsConsumed:
        return '✅';
      case BatchOperationType.markAsWasted:
        return '❌';
      case BatchOperationType.export:
        return '📤';
    }
  }
}
