import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

class AuthRegister {
  final AuthRepository authRepository;

  const AuthRegister({
    required this.authRepository,
  });

  Future<Either<Failure, void>> call(
    String email,
    String password,
    String name,
  ) async {
    return await authRepository.register(
      email,
      password,
      name,
    );
  }
}
