import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class AuthLogin {
  final AuthRepository authRepository;

  const AuthLogin({
    required this.authRepository,
  });

  Future<Either<Failure, Auth>> call(String email, String password) async {
    return await authRepository.login(email, password);
  }
}
