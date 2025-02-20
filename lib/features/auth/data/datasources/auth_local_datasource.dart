import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDatasource {
  Future<void> saveToken(String token);
  Future<void> deleteToken();
}

class AuthLocalDatasourceImplementation extends AuthLocalDatasource {
  final SharedPreferences sharedPreferences;

  AuthLocalDatasourceImplementation({
    required this.sharedPreferences,
  });

  @override
  Future<void> saveToken(String token) async {
    await sharedPreferences.setString('token', token);
  }

  @override
  Future<void> deleteToken() async {
    await sharedPreferences.remove('token');
  }
}