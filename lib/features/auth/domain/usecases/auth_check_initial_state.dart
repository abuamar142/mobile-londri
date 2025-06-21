import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class AuthCheckInitialState {
  final AuthRepository authRepository;

  AuthCheckInitialState({
    required this.authRepository,
  });

  Future<Either<Failure, Auth?>> call() async {
    return await authRepository.checkInitialState();
  }
}
