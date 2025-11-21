import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/waste_record.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/entities/achievement.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static const String _keyWasteRecords = 'waste_records';
  static const String _keyUserStats = 'user_stats';
  static const String _keyUnlockedAchievements = 'unlocked_achievements';

  // Waste Records Management
  Future<void> addWasteRecord(WasteRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getWasteRecords();
    records.add(record);

    final jsonList = records.map((r) => r.toMap()).toList();
    await prefs.setString(_keyWasteRecords, json.encode(jsonList));

    // Update stats
    await _updateStatsOnWaste(record);
  }

  Future<List<WasteRecord>> getWasteRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyWasteRecords);

    if (jsonString == null) return [];

    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((json) => WasteRecord.fromMap(json)).toList();
  }

  Future<List<WasteRecord>> getWasteRecordsInDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final allRecords = await getWasteRecords();
    return allRecords.where((record) {
      return record.wasteDate.isAfter(start) &&
          record.wasteDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> deleteWasteRecord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getWasteRecords();
    records.removeWhere((r) => r.id == id);

    final jsonList = records.map((r) => r.toMap()).toList();
    await prefs.setString(_keyWasteRecords, json.encode(jsonList));
  }

  // User Stats Management
  Future<UserStats> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUserStats);

    if (jsonString == null) {
      return UserStats(lastActivityDate: DateTime.now());
    }

    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return UserStats.fromMap(jsonMap);
  }

  Future<void> saveUserStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserStats, json.encode(stats.toMap()));
  }

  Future<void> _updateStatsOnWaste(WasteRecord record) async {
    final stats = await getUserStats();

    // Update waste count
    final newWasteCount = stats.totalProductsWasted + record.quantity;

    // Update category waste
    final categoryWaste = Map<String, int>.from(stats.categoryWaste);
    categoryWaste[record.category] =
        (categoryWaste[record.category] ?? 0) + record.quantity;

    // Update monthly waste
    final monthKey = '${record.wasteDate.year}-${record.wasteDate.month}';
    final monthlyWaste = Map<String, int>.from(stats.monthlyWaste);
    monthlyWaste[monthKey] = (monthlyWaste[monthKey] ?? 0) + record.quantity;

    // Update total waste cost
    final newWasteCost = stats.totalWasteCost + (record.estimatedCost ?? 0);

    // Reset streak if waste occurred today
    final today = DateTime.now();
    final isToday = record.wasteDate.year == today.year &&
        record.wasteDate.month == today.month &&
        record.wasteDate.day == today.day;

    final newStreak = isToday ? 0 : stats.currentStreak;

    final updatedStats = stats.copyWith(
      totalProductsWasted: newWasteCount,
      categoryWaste: categoryWaste,
      monthlyWaste: monthlyWaste,
      totalWasteCost: newWasteCost,
      currentStreak: newStreak,
      lastActivityDate: DateTime.now(),
    );

    await saveUserStats(updatedStats);
  }

  Future<void> incrementProductsAdded() async {
    final stats = await getUserStats();
    final updatedStats = stats.copyWith(
      totalProductsAdded: stats.totalProductsAdded + 1,
      lastActivityDate: DateTime.now(),
    );
    await saveUserStats(updatedStats);

    // Check for achievements
    await _checkAchievements(updatedStats);
  }

  Future<void> incrementProductsSaved(double? savedCost) async {
    final stats = await getUserStats();
    await _updateStreak(stats);

    final updatedStats = stats.copyWith(
      totalProductsSaved: stats.totalProductsSaved + 1,
      totalSavingsCost: stats.totalSavingsCost + (savedCost ?? 0),
      lastActivityDate: DateTime.now(),
    );
    await saveUserStats(updatedStats);

    // Check for achievements
    await _checkAchievements(updatedStats);
  }

  Future<void> incrementScans() async {
    final stats = await getUserStats();
    final updatedStats = stats.copyWith(
      totalScans: stats.totalScans + 1,
      lastActivityDate: DateTime.now(),
    );
    await saveUserStats(updatedStats);

    // Check for achievements
    await _checkAchievements(updatedStats);
  }

  Future<void> _updateStreak(UserStats stats) async {
    final now = DateTime.now();
    final lastActivity = stats.lastActivityDate;

    // Check if last activity was yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    final isConsecutive = lastActivity.year == yesterday.year &&
        lastActivity.month == yesterday.month &&
        lastActivity.day == yesterday.day;

    // Check if last activity was today
    final isToday = lastActivity.year == now.year &&
        lastActivity.month == now.month &&
        lastActivity.day == now.day;

    int newStreak = stats.currentStreak;
    if (isConsecutive) {
      newStreak = stats.currentStreak + 1;
    } else if (!isToday) {
      newStreak = 1; // Start new streak
    }

    final newLongestStreak = newStreak > stats.longestStreak
        ? newStreak
        : stats.longestStreak;

    final updatedStats = stats.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
    );

    await saveUserStats(updatedStats);
  }

  // Achievements Management
  Future<List<Achievement>> getAchievements() async {
    final unlockedTypes = await _getUnlockedAchievementTypes();
    final allAchievements = Achievement.getAllAchievements();

    return allAchievements.map((achievement) {
      final isUnlocked = unlockedTypes.contains(achievement.type);
      return achievement.copyWith(
        isUnlocked: isUnlocked,
        unlockedAt: isUnlocked ? DateTime.now() : null,
      );
    }).toList();
  }

  Future<Set<AchievementType>> _getUnlockedAchievementTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUnlockedAchievements);

    if (jsonString == null) return {};

    final list = json.decode(jsonString) as List;
    return list
        .map((name) => AchievementType.values.firstWhere(
              (e) => e.name == name,
              orElse: () => AchievementType.firstProduct,
            ))
        .toSet();
  }

  Future<void> _unlockAchievement(AchievementType type) async {
    final unlockedTypes = await _getUnlockedAchievementTypes();

    if (unlockedTypes.contains(type)) return; // Already unlocked

    unlockedTypes.add(type);

    final prefs = await SharedPreferences.getInstance();
    final list = unlockedTypes.map((e) => e.name).toList();
    await prefs.setString(_keyUnlockedAchievements, json.encode(list));

    // Add points
    final achievement = Achievement.getAllAchievements()
        .firstWhere((a) => a.type == type);
    final stats = await getUserStats();
    final updatedStats = stats.copyWith(
      totalPoints: stats.totalPoints + achievement.points,
    );
    await saveUserStats(updatedStats);
  }

  Future<void> _checkAchievements(UserStats stats) async {
    // Check first product
    if (stats.totalProductsAdded >= 1) {
      await _unlockAchievement(AchievementType.firstProduct);
    }

    // Check scanner achievements
    if (stats.totalScans >= 50) {
      await _unlockAchievement(AchievementType.scanner50);
    }
    if (stats.totalScans >= 100) {
      await _unlockAchievement(AchievementType.scanner100);
    }

    // Check product count achievements
    if (stats.totalProductsAdded >= 50) {
      await _unlockAchievement(AchievementType.products50);
    }
    if (stats.totalProductsAdded >= 100) {
      await _unlockAchievement(AchievementType.products100);
    }

    // Check waste achievements
    if (stats.currentStreak >= 7) {
      await _unlockAchievement(AchievementType.noWasteWeek);
    }
    if (stats.currentStreak >= 30) {
      await _unlockAchievement(AchievementType.noWasteMonth);
    }

    // Check saved products
    if (stats.totalProductsSaved >= 100) {
      await _unlockAchievement(AchievementType.zeroWasteWarrior);
    }
    if (stats.totalProductsSaved >= 50) {
      await _unlockAchievement(AchievementType.earlyBird);
    }
  }

  Future<void> checkStorageLocationAchievement(int uniqueLocations) async {
    if (uniqueLocations >= 5) {
      await _unlockAchievement(AchievementType.organized);
    }
  }

  // Analytics Calculations
  Future<Map<String, int>> getCategoryWasteStats() async {
    final stats = await getUserStats();
    return stats.categoryWaste;
  }

  Future<Map<String, int>> getMonthlyWasteStats() async {
    final stats = await getUserStats();
    return stats.monthlyWaste;
  }

  Future<double> getTotalWasteCost() async {
    final stats = await getUserStats();
    return stats.totalWasteCost;
  }

  Future<double> getTotalSavingsCost() async {
    final stats = await getUserStats();
    return stats.totalSavingsCost;
  }

  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyWasteRecords);
    await prefs.remove(_keyUserStats);
    await prefs.remove(_keyUnlockedAchievements);
  }
}
