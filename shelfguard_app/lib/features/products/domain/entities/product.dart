import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String category;
  final DateTime expiryDate;
  final int quantity;
  final String? barcode;
  final String? notes;
  final List<String>? photos; // Photo file paths
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.expiryDate,
    this.quantity = 1,
    this.barcode,
    this.notes,
    this.photos,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate days to expiry
  int get daysToExpiry {
    final now = DateTime.now();
    final difference = expiryDate.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  // Check if product is expired
  bool get isExpired => daysToExpiry < 0;

  // Check if product is expiring soon (within 7 days)
  bool get isExpiringSoon => daysToExpiry >= 0 && daysToExpiry <= 7;

  // Check if product is critical (within 3 days)
  bool get isCritical => daysToExpiry >= 0 && daysToExpiry <= 3;

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        expiryDate,
        quantity,
        barcode,
        notes,
        photos,
        createdAt,
        updatedAt,
      ];

  Product copyWith({
    String? id,
    String? name,
    String? category,
    DateTime? expiryDate,
    int? quantity,
    String? barcode,
    String? notes,
    List<String>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      barcode: barcode ?? this.barcode,
      notes: notes ?? this.notes,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
