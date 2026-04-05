import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthGoogleLoginRequested extends AuthEvent {}

class AuthAppleLoginRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  const AuthForgotPasswordRequested({required this.email});
  @override
  List<Object?> get props => [email];
}

class AuthProfileUpdateRequested extends AuthEvent {
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;

  const AuthProfileUpdateRequested({
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [name, email, phone, avatarUrl];
}

class AuthSendEmailVerificationRequested extends AuthEvent {}

class AuthCheckEmailVerificationRequested extends AuthEvent {}
