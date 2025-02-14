import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

class AuthLogout {
  final AuthRepository authRepository;

  AuthLogout({
    required this.authRepository,
  });

  Future<Either<Failure, void>> call() async {
    return await authRepository.logout();
  }
}
