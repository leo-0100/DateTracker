import 'dart:convert';
import 'package:http/http.dart' as http;

/// Product information from external database
class ProductInfo {
  final String barcode;
  final String? name;
  final String? brand;
  final String? imageUrl;
  final String? category;
  final Map<String, dynamic>? nutritionFacts;

  ProductInfo({
    required this.barcode,
    this.name,
    this.brand,
    this.imageUrl,
    this.category,
    this.nutritionFacts,
  });

  factory ProductInfo.fromOpenFoodFacts(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    if (product == null) {
      return ProductInfo(barcode: json['code'] ?? '');
    }

    return ProductInfo(
      barcode: json['code'] ?? '',
      name: product['product_name'] ?? product['generic_name'],
      brand: product['brands'],
      imageUrl: product['image_url'] ?? product['image_front_url'],
      category: product['categories'],
      nutritionFacts: product['nutriments'] as Map<String, dynamic>?,
    );
  }
}

/// Service to fetch product information from external databases
class ProductDatabaseService {
  static const String _openFoodFactsBaseUrl =
      'https://world.openfoodfacts.org/api/v2';

  /// Fetch product info from Open Food Facts
  Future<ProductInfo?> fetchProductInfo(String barcode) async {
    try {
      print('[ProductDB] Fetching info for barcode: $barcode');

      final url = Uri.parse('$_openFoodFactsBaseUrl/product/$barcode.json');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status'] as int?;

        if (status == 1) {
          // Product found
          final productInfo = ProductInfo.fromOpenFoodFacts(data);
          print('[ProductDB] Product found: ${productInfo.name}');
          return productInfo;
        } else {
          // Product not found
          print('[ProductDB] Product not found in database');
          return null;
        }
      } else {
        print('[ProductDB] HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[ProductDB] Error fetching product info: $e');
      return null;
    }
  }

  /// Search products by name
  Future<List<ProductInfo>> searchProducts(String query) async {
    try {
      print('[ProductDB] Searching for: $query');

      final url = Uri.parse(
        '$_openFoodFactsBaseUrl/search?search_terms=$query&page_size=20&json=true',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final products = data['products'] as List?;

        if (products != null) {
          return products
              .map((p) =>
                  ProductInfo.fromOpenFoodFacts({'code': p['code'], 'product': p}))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('[ProductDB] Error searching products: $e');
      return [];
    }
  }

  /// Get suggested category based on barcode prefix
  String? suggestCategory(String barcode) {
    if (barcode.length < 3) return null;

    // Common barcode prefixes (simplified)
    final prefix = barcode.substring(0, 2);

    switch (prefix) {
      case '02': // Dairy
        return 'Dairy';
      case '03': // Meat
        return 'Meat & Seafood';
      case '04': // Produce
        return 'Fruits & Vegetables';
      case '05': // Bakery
        return 'Bakery';
      case '06': // Beverage
        return 'Beverages';
      case '07': // Frozen
        return 'Frozen Foods';
      default:
        return null;
    }
  }

  /// Get typical shelf life for a category (in days)
  int? getTypicalShelfLife(String? category) {
    if (category == null) return null;

    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('dairy') || categoryLower.contains('milk')) {
      return 7; // 1 week
    } else if (categoryLower.contains('meat') ||
        categoryLower.contains('seafood')) {
      return 3; // 3 days
    } else if (categoryLower.contains('vegetable') ||
        categoryLower.contains('fruit') ||
        categoryLower.contains('produce')) {
      return 5; // 5 days
    } else if (categoryLower.contains('bakery') ||
        categoryLower.contains('bread')) {
      return 4; // 4 days
    } else if (categoryLower.contains('frozen')) {
      return 90; // 3 months
    } else if (categoryLower.contains('canned') ||
        categoryLower.contains('packaged')) {
      return 365; // 1 year
    } else if (categoryLower.contains('beverage') ||
        categoryLower.contains('drink')) {
      return 30; // 1 month
    }

    return 30; // Default: 1 month
  }
}
