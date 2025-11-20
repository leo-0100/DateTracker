import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String ownerId;
  final List<int> defaultNotificationDays;
  final String? notificationTime; // Format: "HH:mm"
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Shop({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    required this.ownerId,
    required this.defaultNotificationDays,
    this.notificationTime,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        address,
        phone,
        email,
        ownerId,
        defaultNotificationDays,
        notificationTime,
        notificationsEnabled,
        createdAt,
        updatedAt,
      ];
}
