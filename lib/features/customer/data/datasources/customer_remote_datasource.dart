import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDatasource {
  Future<List<CustomerModel>> readCustomers();
  Future<void> createCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
  Future<void> activateCustomer(String id);
}

class CustomerRemoteDatasourceImplementation extends CustomerRemoteDatasource {
  final SupabaseClient supabaseClient;

  CustomerRemoteDatasourceImplementation({
    required this.supabaseClient,
  });

  @override
  Future<List<CustomerModel>> readCustomers() async {
    try {
      final List<Map<String, dynamic>> response = await supabaseClient
          .from(
            'customers',
          )
          .select()
          .order('created_at', ascending: false);

      return response.map((e) => CustomerModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> createCustomer(CustomerModel customer) async {
    try {
      await supabaseClient
          .from(
            'customers',
          )
          .insert(customer.toJson());
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await supabaseClient
          .from(
            'customers',
          )
          .update(customer.toUpdateJson(customer))
          .eq('id', customer.id!);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteCustomer(String id) {
    try {
      return supabaseClient
          .from(
        'customers',
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

  @override
  Future<void> activateCustomer(String id) {
    try {
      return supabaseClient
          .from(
        'customers',
      )
          .update(
        {
          'deleted_at': null,
        },
      ).eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
