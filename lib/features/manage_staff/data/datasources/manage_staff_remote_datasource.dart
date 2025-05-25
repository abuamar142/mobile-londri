import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class ManageStaffRemoteDatasource {
  Future<void> updateRoleToAdmin(String userId);
  Future<List<UserModel>> readUsers();
  Future<void> updateRoleToUser(String userId);
}

class ManageStaffRemoteDataSourceImplementation extends ManageStaffRemoteDatasource {
  final SupabaseClient supabaseClient;

  ManageStaffRemoteDataSourceImplementation({
    required this.supabaseClient,
  });

  @override
  Future<void> updateRoleToAdmin(String userId) {
    try {
      return supabaseClient.from('user_roles').update({'role': 'admin'}).eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<UserModel>> readUsers() async {
    try {
      final List<Map<String, dynamic>> response =
          await supabaseClient.from('users').select('user_id, email, name, created_at, updated_at, role_id(role)').order('created_at', ascending: false);

      List<Map<String, dynamic>> filteredResponse = response.where((user) => user['role_id']['role'] != 'super_admin').toList();

      return filteredResponse.map((e) => UserModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateRoleToUser(String userId) {
    try {
      return supabaseClient.from('user_roles').update({'role': 'user'}).eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
