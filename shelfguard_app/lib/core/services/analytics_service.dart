import '../../features/products/domain/entities/product.dart';

/// Analytics data model
class ProductAnalytics {
  final int totalProducts;
  final int expiredProducts;
  final int expiringSoonProducts;
  final int freshProducts;

  final Map<String, int> categoryDistribution;
  final Map<String, int> expiryTrends; // Days -> Count

  final double averageDaysToExpiry;
  final String mostCommonCategory;
  final String leastCommonCategory;

  final int totalQuantity;
  final double estimatedWastePercentage;

  ProductAnalytics({
    required this.totalProducts,
    required this.expiredProducts,
    required this.expiringSoonProducts,
    required this.freshProducts,
    required this.categoryDistribution,
    required this.expiryTrends,
    required this.averageDaysToExpiry,
    required this.mostCommonCategory,
    required this.leastCommonCategory,
    required this.totalQuantity,
    required this.estimatedWastePercentage,
  });
}

/// Waste tracking model
class WasteRecord {
  final String productId;
  final String productName;
  final String category;
  final int quantity;
  final DateTime wastedDate;
  final String reason; // 'expired', 'spoiled', 'other'
  final double? estimatedValue; // Money lost

  WasteRecord({
    required this.productId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.wastedDate,
    required this.reason,
    this.estimatedValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'category': category,
      'quantity': quantity,
      'wastedDate': wastedDate.toIso8601String(),
      'reason': reason,
      'estimatedValue': estimatedValue,
    };
  }

  factory WasteRecord.fromJson(Map<String, dynamic> json) {
    return WasteRecord(
      productId: json['productId'],
      productName: json['productName'],
      category: json['category'],
      quantity: json['quantity'],
      wastedDate: DateTime.parse(json['wastedDate']),
      reason: json['reason'],
      estimatedValue: json['estimatedValue'],
    );
  }
}

/// Service for analytics and insights
class AnalyticsService {
  /// Generate comprehensive analytics from products
  ProductAnalytics generateAnalytics(List<Product> products) {
    if (products.isEmpty) {
      return ProductAnalytics(
        totalProducts: 0,
        expiredProducts: 0,
        expiringSoonProducts: 0,
        freshProducts: 0,
        categoryDistribution: {},
        expiryTrends: {},
        averageDaysToExpiry: 0,
        mostCommonCategory: '',
        leastCommonCategory: '',
        totalQuantity: 0,
        estimatedWastePercentage: 0,
      );
    }

    // Basic counts
    final expired = products.where((p) => p.isExpired).length;
    final expiringSoon =
        products.where((p) => !p.isExpired && p.daysToExpiry <= 3).length;
    final fresh = products.where((p) => p.daysToExpiry > 3).length;

    // Category distribution
    final categoryDist = <String, int>{};
    for (final product in products) {
      categoryDist[product.category] =
          (categoryDist[product.category] ?? 0) + 1;
    }

    // Expiry trends (group by days to expiry)
    final expiryTrends = <String, int>{};
    for (final product in products) {
      final days = product.daysToExpiry;
      final key = _getExpiryTrendKey(days);
      expiryTrends[key] = (expiryTrends[key] ?? 0) + 1;
    }

    // Average days to expiry
    final totalDays = products.fold<int>(0, (sum, p) => sum + p.daysToExpiry);
    final avgDays = totalDays / products.length;

    // Most/Least common category
    final sortedCategories = categoryDist.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final mostCommon =
        sortedCategories.isNotEmpty ? sortedCategories.first.key : '';
    final leastCommon =
        sortedCategories.isNotEmpty ? sortedCategories.last.key : '';

    // Total quantity
    final totalQty = products.fold<int>(0, (sum, p) => sum + p.quantity);

    // Estimated waste percentage (expired / total)
    final wastePercentage = (expired / products.length) * 100;

    return ProductAnalytics(
      totalProducts: products.length,
      expiredProducts: expired,
      expiringSoonProducts: expiringSoon,
      freshProducts: fresh,
      categoryDistribution: categoryDist,
      expiryTrends: expiryTrends,
      averageDaysToExpiry: avgDays,
      mostCommonCategory: mostCommon,
      leastCommonCategory: leastCommon,
      totalQuantity: totalQty,
      estimatedWastePercentage: wastePercentage,
    );
  }

  /// Get expiry trend key for grouping
  String _getExpiryTrendKey(int days) {
    if (days < 0) return 'Expired';
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days <= 3) return '2-3 days';
    if (days <= 7) return '4-7 days';
    if (days <= 14) return '1-2 weeks';
    if (days <= 30) return '2-4 weeks';
    return '1+ months';
  }

  /// Calculate money saved by preventing waste
  double calculateMoneySaved(List<WasteRecord> wasteRecords) {
    return wasteRecords.fold<double>(
      0,
      (sum, record) => sum + (record.estimatedValue ?? 0),
    );
  }

  /// Calculate carbon footprint saved (simplified model)
  /// Average: 2.5 kg CO2 per kg of food waste
  double calculateCarbonSaved(int productsNotWasted) {
    // Assume average product weight: 0.5 kg
    final avgWeightKg = 0.5;
    final co2PerKg = 2.5; // kg CO2 per kg food waste
    return productsNotWasted * avgWeightKg * co2PerKg;
  }

  /// Get waste trends by category
  Map<String, int> getWasteTrendsByCategory(List<WasteRecord> records) {
    final trends = <String, int>{};
    for (final record in records) {
      trends[record.category] = (trends[record.category] ?? 0) + record.quantity;
    }
    return trends;
  }

  /// Get waste trends by month
  Map<String, int> getWasteTrendsByMonth(List<WasteRecord> records) {
    final trends = <String, int>{};
    for (final record in records) {
      final key = '${record.wastedDate.year}-${record.wastedDate.month.toString().padLeft(2, '0')}';
      trends[key] = (trends[key] ?? 0) + 1;
    }
    return trends;
  }

  /// Get insights and recommendations
  List<String> getInsights(ProductAnalytics analytics) {
    final insights = <String>[];

    // Waste percentage insight
    if (analytics.estimatedWastePercentage > 20) {
      insights.add(
          '⚠️ ${analytics.estimatedWastePercentage.toStringAsFixed(1)}% of your products are expired. Consider buying smaller quantities.');
    } else if (analytics.estimatedWastePercentage < 5) {
      insights.add(
          '✅ Great job! Only ${analytics.estimatedWastePercentage.toStringAsFixed(1)}% waste rate.');
    }

    // Expiring soon alert
    if (analytics.expiringSoonProducts > 0) {
      insights.add(
          '⏰ You have ${analytics.expiringSoonProducts} product(s) expiring in the next 3 days.');
    }

    // Category insight
    if (analytics.mostCommonCategory.isNotEmpty) {
      final count = analytics.categoryDistribution[analytics.mostCommonCategory] ?? 0;
      insights.add(
          '📊 Most stored category: ${analytics.mostCommonCategory} ($count items)');
    }

    // Average expiry insight
    if (analytics.averageDaysToExpiry < 7) {
      insights.add(
          '🔄 Average expiry in ${analytics.averageDaysToExpiry.toStringAsFixed(0)} days. Consider rotating stock more frequently.');
    }

    return insights;
  }

  /// Generate summary stats for dashboard
  Map<String, String> getSummaryStats(ProductAnalytics analytics) {
    return {
      'Total Products': analytics.totalProducts.toString(),
      'Expired': analytics.expiredProducts.toString(),
      'Expiring Soon': analytics.expiringSoonProducts.toString(),
      'Fresh': analytics.freshProducts.toString(),
      'Avg Days to Expiry': analytics.averageDaysToExpiry.toStringAsFixed(1),
      'Waste Rate': '${analytics.estimatedWastePercentage.toStringAsFixed(1)}%',
    };
  }
}
