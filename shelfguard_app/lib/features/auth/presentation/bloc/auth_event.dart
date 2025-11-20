import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email]; // Don't include password in props for security
}

class SignupRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const SignupRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email]; // Don't include password in props for security
}

class LogoutRequested extends AuthEvent {}
