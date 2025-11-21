import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  final int totalProductsAdded;
  final int totalProductsWasted;
  final int totalProductsSaved;
  final int currentStreak;
  final int longestStreak;
  final double totalWasteCost;
  final double totalSavingsCost;
  final int totalScans;
  final int totalPoints;
  final DateTime lastActivityDate;
  final Map<String, int> categoryWaste;
  final Map<String, int> monthlyWaste;

  const UserStats({
    this.totalProductsAdded = 0,
    this.totalProductsWasted = 0,
    this.totalProductsSaved = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalWasteCost = 0.0,
    this.totalSavingsCost = 0.0,
    this.totalScans = 0,
    this.totalPoints = 0,
    required this.lastActivityDate,
    this.categoryWaste = const {},
    this.monthlyWaste = const {},
  });

  @override
  List<Object?> get props => [
        totalProductsAdded,
        totalProductsWasted,
        totalProductsSaved,
        currentStreak,
        longestStreak,
        totalWasteCost,
        totalSavingsCost,
        totalScans,
        totalPoints,
        lastActivityDate,
        categoryWaste,
        monthlyWaste,
      ];

  double get wastePercentage {
    if (totalProductsAdded == 0) return 0.0;
    return (totalProductsWasted / totalProductsAdded) * 100;
  }

  double get savePercentage {
    if (totalProductsAdded == 0) return 0.0;
    return (totalProductsSaved / totalProductsAdded) * 100;
  }

  UserStats copyWith({
    int? totalProductsAdded,
    int? totalProductsWasted,
    int? totalProductsSaved,
    int? currentStreak,
    int? longestStreak,
    double? totalWasteCost,
    double? totalSavingsCost,
    int? totalScans,
    int? totalPoints,
    DateTime? lastActivityDate,
    Map<String, int>? categoryWaste,
    Map<String, int>? monthlyWaste,
  }) {
    return UserStats(
      totalProductsAdded: totalProductsAdded ?? this.totalProductsAdded,
      totalProductsWasted: totalProductsWasted ?? this.totalProductsWasted,
      totalProductsSaved: totalProductsSaved ?? this.totalProductsSaved,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalWasteCost: totalWasteCost ?? this.totalWasteCost,
      totalSavingsCost: totalSavingsCost ?? this.totalSavingsCost,
      totalScans: totalScans ?? this.totalScans,
      totalPoints: totalPoints ?? this.totalPoints,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      categoryWaste: categoryWaste ?? this.categoryWaste,
      monthlyWaste: monthlyWaste ?? this.monthlyWaste,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalProductsAdded': totalProductsAdded,
      'totalProductsWasted': totalProductsWasted,
      'totalProductsSaved': totalProductsSaved,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalWasteCost': totalWasteCost,
      'totalSavingsCost': totalSavingsCost,
      'totalScans': totalScans,
      'totalPoints': totalPoints,
      'lastActivityDate': lastActivityDate.toIso8601String(),
      'categoryWaste': categoryWaste,
      'monthlyWaste': monthlyWaste,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalProductsAdded: map['totalProductsAdded'] as int? ?? 0,
      totalProductsWasted: map['totalProductsWasted'] as int? ?? 0,
      totalProductsSaved: map['totalProductsSaved'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      totalWasteCost: (map['totalWasteCost'] as num?)?.toDouble() ?? 0.0,
      totalSavingsCost: (map['totalSavingsCost'] as num?)?.toDouble() ?? 0.0,
      totalScans: map['totalScans'] as int? ?? 0,
      totalPoints: map['totalPoints'] as int? ?? 0,
      lastActivityDate: DateTime.parse(map['lastActivityDate'] as String),
      categoryWaste: Map<String, int>.from(map['categoryWaste'] as Map? ?? {}),
      monthlyWaste: Map<String, int>.from(map['monthlyWaste'] as Map? ?? {}),
    );
  }
}
