import 'package:dio/dio.dart';

class ProductInfo {
  final String? name;
  final String? brand;
  final String? category;
  final String? imageUrl;
  final int? shelfLifeDays;

  ProductInfo({
    this.name,
    this.brand,
    this.category,
    this.imageUrl,
    this.shelfLifeDays,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    try {
      final product = json['product'] as Map<String, dynamic>?;

      if (product == null) {
        return ProductInfo();
      }

      // Extract product name
      String? productName = product['product_name'] as String?;
      if (productName == null || productName.isEmpty) {
        productName = product['product_name_en'] as String?;
      }

      // Extract brand
      final brand = product['brands'] as String?;

      // Extract category - try to get the most specific one
      String? category;
      final categories = product['categories'] as String?;
      if (categories != null && categories.isNotEmpty) {
        final categoryList = categories.split(',');
        category = categoryList.last.trim();
        // Map to our app categories
        category = _mapToAppCategory(category);
      }

      // Extract image URL
      final imageUrl = product['image_url'] as String? ??
          product['image_front_url'] as String?;

      return ProductInfo(
        name: productName,
        brand: brand,
        category: category,
        imageUrl: imageUrl,
        shelfLifeDays: null, // Open Food Facts doesn't provide shelf life
      );
    } catch (e) {
      print('Error parsing Open Food Facts response: $e');
      return ProductInfo();
    }
  }

  static String _mapToAppCategory(String offCategory) {
    final lowerCategory = offCategory.toLowerCase();

    // Map Open Food Facts categories to app categories
    if (lowerCategory.contains('dairy') ||
        lowerCategory.contains('milk') ||
        lowerCategory.contains('cheese') ||
        lowerCategory.contains('yogurt')) {
      return 'Dairy';
    } else if (lowerCategory.contains('meat') ||
        lowerCategory.contains('poultry') ||
        lowerCategory.contains('beef') ||
        lowerCategory.contains('pork') ||
        lowerCategory.contains('chicken')) {
      return 'Meat';
    } else if (lowerCategory.contains('fruit')) {
      return 'Fruits';
    } else if (lowerCategory.contains('vegetable') ||
        lowerCategory.contains('veggies')) {
      return 'Vegetables';
    } else if (lowerCategory.contains('beverage') ||
        lowerCategory.contains('drink') ||
        lowerCategory.contains('juice') ||
        lowerCategory.contains('soda')) {
      return 'Beverages';
    } else if (lowerCategory.contains('snack') ||
        lowerCategory.contains('chip') ||
        lowerCategory.contains('cookie')) {
      return 'Snacks';
    } else if (lowerCategory.contains('frozen')) {
      return 'Frozen';
    } else if (lowerCategory.contains('bakery') ||
        lowerCategory.contains('bread') ||
        lowerCategory.contains('pastry')) {
      return 'Bakery';
    } else if (lowerCategory.contains('sauce') ||
        lowerCategory.contains('condiment') ||
        lowerCategory.contains('dressing')) {
      return 'Condiments';
    } else if (lowerCategory.contains('cereal') ||
        lowerCategory.contains('grain') ||
        lowerCategory.contains('pasta') ||
        lowerCategory.contains('rice')) {
      return 'Grains';
    } else {
      return 'Other';
    }
  }

  bool get isValid =>
      name != null && name!.isNotEmpty;
}

class OpenFoodFactsService {
  static final OpenFoodFactsService _instance =
      OpenFoodFactsService._internal();
  factory OpenFoodFactsService() => _instance;
  OpenFoodFactsService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://world.openfoodfacts.org/api/v2',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<ProductInfo?> getProductByBarcode(String barcode) async {
    try {
      print('Fetching product info for barcode: $barcode');

      final response = await _dio.get('/product/$barcode.json');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final status = data['status'] as int?;

        if (status == 1) {
          // Product found
          final productInfo = ProductInfo.fromJson(data);
          print('Product found: ${productInfo.name}');
          return productInfo;
        } else {
          print('Product not found in Open Food Facts database');
          return null;
        }
      } else {
        print('API request failed with status: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        print('Request timeout while fetching product info');
      } else if (e.type == DioExceptionType.connectionError) {
        print('Connection error while fetching product info');
      } else {
        print('Error fetching product info: ${e.message}');
      }
      return null;
    } catch (e) {
      print('Unexpected error fetching product info: $e');
      return null;
    }
  }

  Future<List<ProductInfo>> searchProducts(String query) async {
    try {
      print('Searching products: $query');

      final response = await _dio.get('/search', queryParameters: {
        'search_terms': query,
        'page_size': 20,
        'json': true,
      });

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final products = data['products'] as List<dynamic>?;

        if (products == null || products.isEmpty) {
          return [];
        }

        return products
            .map((product) => ProductInfo.fromJson({'product': product}))
            .where((info) => info.isValid)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Get typical shelf life for common product categories
  static int? getTypicalShelfLifeDays(String category) {
    switch (category) {
      case 'Dairy':
        return 7; // Typical dairy shelf life
      case 'Meat':
        return 3; // Fresh meat
      case 'Fruits':
        return 5; // Average fruit shelf life
      case 'Vegetables':
        return 7; // Average vegetable shelf life
      case 'Beverages':
        return 90; // Typical for bottled drinks
      case 'Snacks':
        return 180; // Packaged snacks
      case 'Frozen':
        return 180; // Frozen foods
      case 'Bakery':
        return 3; // Fresh bakery items
      case 'Condiments':
        return 90; // Opened condiments
      case 'Grains':
        return 365; // Dry grains
      default:
        return 30; // Default shelf life
    }
  }
}
