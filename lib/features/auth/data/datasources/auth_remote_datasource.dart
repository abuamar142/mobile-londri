import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDatasource {
  Future<AuthModel> login(
    String email,
    String password,
  );
  Future<void> register(
    String email,
    String password,
    String name,
  );
  Future<void> logout();
}

class AuthRemoteDatasourceImplementation extends AuthRemoteDatasource {
  final SupabaseClient supabaseClient;

  AuthRemoteDatasourceImplementation({
    required this.supabaseClient,
  });

  @override
  Future<AuthModel> login(
    String email,
    String password,
  ) async {
    try {
      final AuthResponse response =
          await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return AuthModel(
        id: response.user!.id,
        accessToken: response.session!.accessToken,
        email: response.user!.email ?? '',
        name: response.user!.userMetadata!['name'] ?? '',
      );
    } on AuthException catch (e) {
      throw ServerException(message: e.code.toString());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
