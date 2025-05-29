import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/service_model.dart';

abstract class ServiceLocalDatasource {
  Future<ServiceModel> readDefaultService();
  Future<void> createDefaultService(ServiceModel service);
}

class ServiceLocalDatasourceImplementation implements ServiceLocalDatasource {
  final SharedPreferences sharedPreferences;

  ServiceLocalDatasourceImplementation({
    required this.sharedPreferences,
  });

  @override
  Future<ServiceModel> readDefaultService() async {
    try {
      final String? defaultServiceJson = sharedPreferences.getString('default_service');

      if (defaultServiceJson == null || defaultServiceJson.isEmpty) {
        throw ServerException(message: 'No default service found');
      }

      final Map<String, dynamic> jsonData = json.decode(defaultServiceJson);
      return ServiceModel.fromJson(jsonData);
    } on ServerException catch (e) {
      throw ServerException(message: 'Error reading default service: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error reading default service: $e');
    }
  }

  @override
  Future<void> createDefaultService(ServiceModel service) async {
    try {
      final String serviceJson = json.encode(service.toJson());
      await sharedPreferences.setString('default_service', serviceJson);
    } on ServerException catch (e) {
      throw ServerException(message: 'Error saving default service: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error saving default service: $e');
    }
  }
}
