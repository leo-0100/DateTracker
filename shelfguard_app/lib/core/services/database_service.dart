import 'package:hive_flutter/hive_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:typed_data';

/// Database service with encryption for Hive
class DatabaseService {
  static const String _encryptionKeyStorageKey = 'hive_encryption_key';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Initialize Hive with encryption
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Get or generate encryption key
    final encryptionKey = await _getOrCreateEncryptionKey();

    // Open encrypted boxes
    await _openEncryptedBoxes(encryptionKey);
  }

  /// Get existing encryption key or create a new one
  static Future<List<int>> _getOrCreateEncryptionKey() async {
    // Try to retrieve existing key
    final existingKey = await _secureStorage.read(key: _encryptionKeyStorageKey);

    if (existingKey != null) {
      // Decode existing key
      return base64Decode(existingKey);
    }

    // Generate new 256-bit encryption key
    final key = Hive.generateSecureKey();

    // Store key securely
    await _secureStorage.write(
      key: _encryptionKeyStorageKey,
      value: base64Encode(key),
    );

    return key;
  }

  /// Open all encrypted Hive boxes
  static Future<void> _openEncryptedBoxes(List<int> encryptionKey) async {
    try {
      // Create encryption cipher
      final encryptionCipher = HiveAesCipher(encryptionKey);

      // Open encrypted boxes
      // Products box
      if (!Hive.isBoxOpen('products')) {
        await Hive.openBox(
          'products',
          encryptionCipher: encryptionCipher,
        );
      }

      // User data box
      if (!Hive.isBoxOpen('user_data')) {
        await Hive.openBox(
          'user_data',
          encryptionCipher: encryptionCipher,
        );
      }

      // Settings box
      if (!Hive.isBoxOpen('settings')) {
        await Hive.openBox(
          'settings',
          encryptionCipher: encryptionCipher,
        );
      }

      // Cache box (can be unencrypted as it contains non-sensitive data)
      if (!Hive.isBoxOpen('cache')) {
        await Hive.openBox('cache');
      }

      print('[Database] Encrypted boxes initialized successfully');
    } catch (e) {
      print('[Database] Error opening encrypted boxes: $e');
      rethrow;
    }
  }

  /// Get encrypted box
  static Box getBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('Box $boxName is not open. Call initialize() first.');
    }
    return Hive.box(boxName);
  }

  /// Close all boxes
  static Future<void> closeAll() async {
    await Hive.close();
  }

  /// Clear all data (for logout or data reset)
  static Future<void> clearAllData() async {
    try {
      if (Hive.isBoxOpen('products')) {
        await Hive.box('products').clear();
      }
      if (Hive.isBoxOpen('user_data')) {
        await Hive.box('user_data').clear();
      }
      if (Hive.isBoxOpen('settings')) {
        await Hive.box('settings').clear();
      }
      if (Hive.isBoxOpen('cache')) {
        await Hive.box('cache').clear();
      }
      print('[Database] All data cleared');
    } catch (e) {
      print('[Database] Error clearing data: $e');
      rethrow;
    }
  }

  /// Delete all boxes and encryption key (for complete app reset)
  static Future<void> deleteAll() async {
    try {
      await Hive.deleteBoxFromDisk('products');
      await Hive.deleteBoxFromDisk('user_data');
      await Hive.deleteBoxFromDisk('settings');
      await Hive.deleteBoxFromDisk('cache');
      await _secureStorage.delete(key: _encryptionKeyStorageKey);
      print('[Database] All boxes and encryption key deleted');
    } catch (e) {
      print('[Database] Error deleting boxes: $e');
      rethrow;
    }
  }
}
