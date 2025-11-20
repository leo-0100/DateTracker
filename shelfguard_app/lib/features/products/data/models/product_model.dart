import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.shopId,
    super.barcode,
    required super.name,
    super.description,
    required super.quantity,
    required super.unit,
    super.batchNumber,
    super.manufactureDate,
    required super.expiryDate,
    super.location,
    super.notes,
    super.imageUrl,
    required super.status,
    super.customFields,
    super.notificationDays,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      barcode: json['barcode'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      batchNumber: json['batch_number'] as String?,
      manufactureDate: json['manufacture_date'] != null
          ? DateTime.parse(json['manufacture_date'] as String)
          : null,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String,
      customFields: json['custom_fields'] as Map<String, dynamic>? ?? {},
      notificationDays: (json['notification_days'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'barcode': barcode,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'batch_number': batchNumber,
      'manufacture_date': manufactureDate?.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'location': location,
      'notes': notes,
      'image_url': imageUrl,
      'status': status,
      'custom_fields': customFields,
      'notification_days': notificationDays,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product toEntity() {
    return Product(
      id: id,
      shopId: shopId,
      barcode: barcode,
      name: name,
      description: description,
      quantity: quantity,
      unit: unit,
      batchNumber: batchNumber,
      manufactureDate: manufactureDate,
      expiryDate: expiryDate,
      location: location,
      notes: notes,
      imageUrl: imageUrl,
      status: status,
      customFields: customFields,
      notificationDays: notificationDays,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      shopId: product.shopId,
      barcode: product.barcode,
      name: product.name,
      description: product.description,
      quantity: product.quantity,
      unit: product.unit,
      batchNumber: product.batchNumber,
      manufactureDate: product.manufactureDate,
      expiryDate: product.expiryDate,
      location: product.location,
      notes: product.notes,
      imageUrl: product.imageUrl,
      status: product.status,
      customFields: product.customFields,
      notificationDays: product.notificationDays,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }
}
