import 'package:equatable/equatable.dart';

class CustomField extends Equatable {
  final String id;
  final String shopId;
  final String name;
  final String fieldType; // text, number, date, boolean, select
  final bool required;
  final List<String>? selectOptions; // For select type
  final String? defaultValue;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomField({
    required this.id,
    required this.shopId,
    required this.name,
    required this.fieldType,
    required this.required,
    this.selectOptions,
    this.defaultValue,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        shopId,
        name,
        fieldType,
        required,
        selectOptions,
        defaultValue,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}
