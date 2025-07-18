part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogin({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [
        email,
        password,
      ];
}

class AuthEventRegister extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordAgain;

  const AuthEventRegister({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordAgain,
  });

  @override
  List<Object> get props => [
        name,
        email,
        password,
        passwordAgain,
      ];
}

class AuthEventLogout extends AuthEvent {}

class AuthEventCheckInitialState extends AuthEvent {}
