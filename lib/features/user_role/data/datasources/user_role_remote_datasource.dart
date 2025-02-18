import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/profile_model.dart';

abstract class UserRoleRemoteDatasource {
  Future<void> createUserRole(String userId, String roleId);
  Future<List<ProfileModel>> readProfiles();
  Future<void> deleteUserRole(String userId);
}

class UserRoleRemoteDataSourceImplementation extends UserRoleRemoteDatasource {
  final SupabaseClient supabaseClient;

  UserRoleRemoteDataSourceImplementation({
    required this.supabaseClient,
  });

  @override
  Future<void> createUserRole(String userId, String roleId) {
    try {
      return supabaseClient
          .from(
        'user_roles',
      )
          .insert({
        'user_id': userId,
        'role': roleId,
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ProfileModel>> readProfiles() async {
    try {
      final List<Map<String, dynamic>> response = await supabaseClient
          .from(
            'profiles',
          )
          .select();

      return response.map((e) => ProfileModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteUserRole(String userId) {
    try {
      return supabaseClient
          .from(
            'user_roles',
          )
          .delete()
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
