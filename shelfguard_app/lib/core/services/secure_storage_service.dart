import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data like auth tokens
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Keys for stored data
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';

  /// Save authentication token
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Save user data
  Future<void> saveUserData({
    required String userId,
    required String email,
    required String name,
  }) async {
    await Future.wait([
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyUserEmail, value: email),
      _storage.write(key: _keyUserName, value: name),
    ]);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  /// Get user name
  Future<String?> getUserName() async {
    return await _storage.read(key: _keyUserName);
  }

  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all authentication data
  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _keyAuthToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyUserEmail),
      _storage.delete(key: _keyUserName),
    ]);
  }

  /// Delete all stored data (for complete app reset)
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
