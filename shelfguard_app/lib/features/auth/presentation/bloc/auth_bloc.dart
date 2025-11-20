import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/entities/user.dart';
import '../../../../core/services/secure_storage_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SecureStorageService _secureStorage = SecureStorageService();

  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Check if user has valid authentication token
      final isAuthenticated = await _secureStorage.isAuthenticated();

      if (isAuthenticated) {
        // Retrieve user data from secure storage
        final userId = await _secureStorage.getUserId();
        final email = await _secureStorage.getUserEmail();
        final name = await _secureStorage.getUserName();

        if (userId != null && email != null && name != null) {
          final user = User(
            id: userId,
            email: email,
            name: name,
            createdAt: DateTime.now(), // In production, store this in secure storage too
          );
          emit(Authenticated(user: user));
          return;
        }
      }

      emit(Unauthenticated());
    } catch (e) {
      print('Error checking auth status: $e');
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Validate input
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(const AuthError(message: 'Email and password are required'));
        emit(Unauthenticated());
        return;
      }

      // TODO: Replace with actual API call to backend
      // For now, simulate authentication with delay
      await Future.delayed(const Duration(seconds: 1));

      // DEMO MODE: In production, this should verify against a backend
      // For security demonstration, we're showing the structure without a real backend

      // Simulate password verification (in production, done server-side)
      final passwordHash = sha256.convert(utf8.encode(event.password)).toString();

      // Generate mock auth token (in production, received from server)
      final authToken = _generateMockToken(event.email);
      final refreshToken = _generateMockToken('${event.email}_refresh');

      // Store tokens securely
      await _secureStorage.saveAuthToken(authToken);
      await _secureStorage.saveRefreshToken(refreshToken);

      // Create user object (in production, from server response)
      final user = User(
        id: '1',
        email: event.email,
        name: 'Demo User',
        createdAt: DateTime.now(),
      );

      // Store user data securely
      await _secureStorage.saveUserData(
        userId: user.id,
        email: user.email,
        name: user.name,
      );

      emit(Authenticated(user: user));
    } on SocketException {
      emit(const AuthError(message: 'Network error. Check your connection.'));
      emit(Unauthenticated());
    } on TimeoutException {
      emit(const AuthError(message: 'Request timed out. Please try again.'));
      emit(Unauthenticated());
    } catch (e) {
      print('Login error: $e');
      emit(const AuthError(message: 'Authentication failed. Please try again.'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Validate input
      if (event.name.isEmpty || event.email.isEmpty || event.password.isEmpty) {
        emit(const AuthError(message: 'All fields are required'));
        emit(Unauthenticated());
        return;
      }

      // TODO: Replace with actual API call to backend
      // For now, simulate signup with delay
      await Future.delayed(const Duration(seconds: 1));

      // DEMO MODE: In production, this should create user on backend

      // Generate mock auth tokens (in production, received from server)
      final authToken = _generateMockToken(event.email);
      final refreshToken = _generateMockToken('${event.email}_refresh');

      // Store tokens securely
      await _secureStorage.saveAuthToken(authToken);
      await _secureStorage.saveRefreshToken(refreshToken);

      // Create user object
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: event.email,
        name: event.name,
        createdAt: DateTime.now(),
      );

      // Store user data securely
      await _secureStorage.saveUserData(
        userId: user.id,
        email: user.email,
        name: user.name,
      );

      emit(Authenticated(user: user));
    } on SocketException {
      emit(const AuthError(message: 'Network error. Check your connection.'));
      emit(Unauthenticated());
    } on TimeoutException {
      emit(const AuthError(message: 'Request timed out. Please try again.'));
      emit(Unauthenticated());
    } catch (e) {
      print('Signup error: $e');
      emit(const AuthError(message: 'Signup failed. Please try again.'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Clear all secure storage data
      await _secureStorage.clearAll();

      // Clear SharedPreferences (for any cached data)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // In production, also invalidate token on server
      // await _authRepository.logout();

      emit(Unauthenticated());
    } catch (e) {
      print('Logout error: $e');
      // Even if there's an error, still logout locally
      emit(Unauthenticated());
    }
  }

  /// Generate a mock token for demo purposes
  /// In production, tokens should be generated server-side
  String _generateMockToken(String seed) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$seed$timestamp';
    return base64Encode(utf8.encode(data));
  }
}
