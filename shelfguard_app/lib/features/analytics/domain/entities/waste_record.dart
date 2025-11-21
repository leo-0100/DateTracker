import 'package:equatable/equatable.dart';

enum WasteReason {
  expired,
  spoiled,
  forgotten,
  tooMuch,
  other,
}

class WasteRecord extends Equatable {
  final String id;
  final String productName;
  final String category;
  final int quantity;
  final WasteReason reason;
  final double? estimatedCost;
  final DateTime wasteDate;
  final String? notes;

  const WasteRecord({
    required this.id,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.reason,
    this.estimatedCost,
    required this.wasteDate,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        productName,
        category,
        quantity,
        reason,
        estimatedCost,
        wasteDate,
        notes,
      ];

  WasteRecord copyWith({
    String? id,
    String? productName,
    String? category,
    int? quantity,
    WasteReason? reason,
    double? estimatedCost,
    DateTime? wasteDate,
    String? notes,
  }) {
    return WasteRecord(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      wasteDate: wasteDate ?? this.wasteDate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'category': category,
      'quantity': quantity,
      'reason': reason.name,
      'estimatedCost': estimatedCost,
      'wasteDate': wasteDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory WasteRecord.fromMap(Map<String, dynamic> map) {
    return WasteRecord(
      id: map['id'] as String,
      productName: map['productName'] as String,
      category: map['category'] as String,
      quantity: map['quantity'] as int,
      reason: WasteReason.values.firstWhere(
        (e) => e.name == map['reason'],
        orElse: () => WasteReason.other,
      ),
      estimatedCost: map['estimatedCost'] as double?,
      wasteDate: DateTime.parse(map['wasteDate'] as String),
      notes: map['notes'] as String?,
    );
  }
}
