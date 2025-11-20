import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String shopId;
  final String? barcode;
  final String name;
  final String? description;
  final double quantity;
  final String unit;
  final String? batchNumber;
  final DateTime? manufactureDate;
  final DateTime expiryDate;
  final String? location;
  final String? notes;
  final String? imageUrl;
  final String status; // active, disposed, sold, expired
  final Map<String, dynamic> customFields;
  final List<int>? notificationDays; // Override global settings
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.shopId,
    this.barcode,
    required this.name,
    this.description,
    required this.quantity,
    required this.unit,
    this.batchNumber,
    this.manufactureDate,
    required this.expiryDate,
    this.location,
    this.notes,
    this.imageUrl,
    required this.status,
    this.customFields = const {},
    this.notificationDays,
    required this.createdAt,
    required this.updatedAt,
  });

  int get daysToExpiry {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inDays;
  }

  bool get isExpired => daysToExpiry < 0;
  bool get isSoonToExpire => daysToExpiry >= 0 && daysToExpiry <= 7;
  bool get isCritical => daysToExpiry >= 0 && daysToExpiry <= 3;

  @override
  List<Object?> get props => [
        id,
        shopId,
        barcode,
        name,
        description,
        quantity,
        unit,
        batchNumber,
        manufactureDate,
        expiryDate,
        location,
        notes,
        imageUrl,
        status,
        customFields,
        notificationDays,
        createdAt,
        updatedAt,
      ];
}
