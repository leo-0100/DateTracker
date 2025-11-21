import 'package:equatable/equatable.dart';

enum AchievementType {
  firstProduct,
  noWasteWeek,
  noWasteMonth,
  scanner50,
  scanner100,
  products50,
  products100,
  zeroWasteWarrior,
  earlyBird,
  organized,
}

class Achievement extends Equatable {
  final AchievementType type;
  final String title;
  final String description;
  final String icon;
  final int points;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  @override
  List<Object?> get props => [
        type,
        title,
        description,
        icon,
        points,
        isUnlocked,
        unlockedAt,
      ];

  Achievement copyWith({
    AchievementType? type,
    String? title,
    String? description,
    String? icon,
    int? points,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  static List<Achievement> getAllAchievements() {
    return [
      const Achievement(
        type: AchievementType.firstProduct,
        title: 'Getting Started',
        description: 'Add your first product',
        icon: '🎯',
        points: 10,
      ),
      const Achievement(
        type: AchievementType.noWasteWeek,
        title: 'Week Warrior',
        description: 'Go a week without wasting any products',
        icon: '🌟',
        points: 50,
      ),
      const Achievement(
        type: AchievementType.noWasteMonth,
        title: 'Monthly Master',
        description: 'Go a month without wasting any products',
        icon: '🏆',
        points: 200,
      ),
      const Achievement(
        type: AchievementType.scanner50,
        title: 'Scanner Pro',
        description: 'Scan 50 products using barcode scanner',
        icon: '📱',
        points: 75,
      ),
      const Achievement(
        type: AchievementType.scanner100,
        title: 'Scanner Expert',
        description: 'Scan 100 products using barcode scanner',
        icon: '🔍',
        points: 150,
      ),
      const Achievement(
        type: AchievementType.products50,
        title: 'Inventory Keeper',
        description: 'Track 50 products',
        icon: '📦',
        points: 100,
      ),
      const Achievement(
        type: AchievementType.products100,
        title: 'Inventory Master',
        description: 'Track 100 products',
        icon: '🏪',
        points: 250,
      ),
      const Achievement(
        type: AchievementType.zeroWasteWarrior,
        title: 'Zero Waste Warrior',
        description: 'Save 100 products from expiring',
        icon: '♻️',
        points: 300,
      ),
      const Achievement(
        type: AchievementType.earlyBird,
        title: 'Early Bird',
        description: 'Use a product before it expires 50 times',
        icon: '🐦',
        points: 150,
      ),
      const Achievement(
        type: AchievementType.organized,
        title: 'Super Organized',
        description: 'Organize products in 5 different storage locations',
        icon: '🗂️',
        points: 75,
      ),
    ];
  }
}
