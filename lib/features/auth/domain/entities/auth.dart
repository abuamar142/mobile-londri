import 'package:equatable/equatable.dart';

class Auth extends Equatable {
  final String? accessToken;
  final String id;
  final String email;
  final String name;

  const Auth({
    this.accessToken,
    required this.id,
    required this.email,
    required this.name,
  });

  @override
  List<Object?> get props => [
        accessToken,
        id,
        email,
        name,
      ];
}
