import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/service_model.dart';

abstract class ServiceRemoteDatasource {
  Future<List<ServiceModel>> readServices();
  Future<ServiceModel> readServiceById(String id);
  Future<void> createService(ServiceModel service);
  Future<void> updateService(ServiceModel service);
  Future<void> deleteService(String id);
}

class ServiceRemoteDatasourceImplementation extends ServiceRemoteDatasource {
  final SupabaseClient supabaseClient;

  ServiceRemoteDatasourceImplementation({
    required this.supabaseClient,
  });

  @override
  Future<List<ServiceModel>> readServices() async {
    try {
      final List<Map<String, dynamic>> response = await supabaseClient
          .from(
            'services',
          )
          .select()
          .filter('deleted_at', 'is', null);

      return response.map((e) => ServiceModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ServiceModel> readServiceById(String id) async {
    try {
      final Map<String, dynamic> response = await supabaseClient
          .from(
            'services',
          )
          .select()
          .eq('id', id)
          .single();

      return ServiceModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> createService(ServiceModel service) async {
    try {
      await supabaseClient
          .from(
            'services',
          )
          .insert(service.toJson());
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    try {
      await supabaseClient
          .from(
            'services',
          )
          .update(service.toUpdateJson(service))
          .eq('id', service.id!);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteService(String id) {
    try {
      return supabaseClient
          .from(
        'services',
      )
          .update(
        {
          'deleted_at': DateTime.now().toIso8601String(),
        },
      ).eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
