import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/profile_model.dart';

abstract class UserRoleRemoteDatasource {
  Future<void> createUserRole(String userId, String roleId);
  Future<List<ProfileModel>> readProfile();
  Future<void> updateUserRole(String userId, String roleId);
  Future<void> deleteUserRole(String userId);
}

class UserRoleRemoteDataSourceImplementation extends UserRoleRemoteDatasource {
  final SupabaseClient supabaseClient;

  UserRoleRemoteDataSourceImplementation({
    required this.supabaseClient,
  });

  @override
  Future<void> createUserRole(String userId, String roleId) {
    // TODO: implement createUserRole
    throw UnimplementedError();
  }

  @override
  Future<List<ProfileModel>> readProfile() async {
    try {
      final List<Map<String, dynamic>> response =
          await supabaseClient.from('profiles').select();

      print('response: ${jsonEncode(response)}');

      return response.map((e) => ProfileModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateUserRole(String userId, String roleId) {
    // TODO: implement updateUserRole
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUserRole(String userId) {
    // TODO: implement deleteUserRole
    throw UnimplementedError();
  }
}
