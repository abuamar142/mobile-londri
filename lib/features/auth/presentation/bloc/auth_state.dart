part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthStateInitial extends AuthState {}

class AuthStateLoading extends AuthState {}

class AuthStateFailure extends AuthState {
  final String message;

  const AuthStateFailure({
    required this.message,
  });

  @override
  List<Object> get props => [
        message,
      ];
}

class AuthStateSuccessLogin extends AuthState {
  final Auth auth;

  const AuthStateSuccessLogin({
    required this.auth,
  });

  @override
  List<Object> get props => [
        auth,
      ];
}

class AuthStateSuccessRegister extends AuthState {
  final Auth auth;

  const AuthStateSuccessRegister({
    required this.auth,
  });

  @override
  List<Object> get props => [
        auth,
      ];
}

class AuthStateSuccessLogout extends AuthState {}
