import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/auth.dart';
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
  Future<void> saveAuth(
    String userId,
    String accessToken,
  );
  Future<void> logout();
  Future<AuthModel?> checkInitialState();
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
      final AuthResponse response = await supabaseClient.auth.signInWithPassword(
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
  Future<void> saveAuth(String userId, String accessToken) async {
    try {
      final Map<String, dynamic> response = await supabaseClient.from('users').select('''
        id,
        email,
        name
      ''').eq('user_id', userId).single();

      if (response.isNotEmpty) {
        AuthManager.setCurrentUser(
          Auth(
            accessToken: accessToken,
            id: response['id'].toString(),
            email: response['email'],
            name: response['name'],
          ),
        );
      } else {
        throw ServerException(message: 'User not found');
      }
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
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

  @override
  Future<AuthModel?> checkInitialState() async {
    try {
      final session = supabaseClient.auth.currentSession;

      if (session?.user != null) {
        return AuthModel(
          id: session!.user.id,
          accessToken: session.accessToken,
          email: session.user.email ?? '',
          name: session.user.userMetadata?['name'] ?? '',
        );
      }

      return null;
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
