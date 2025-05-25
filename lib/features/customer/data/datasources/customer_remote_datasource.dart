import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/clean_json.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDatasource {
  Future<List<CustomerModel>> readCustomers();
  Future<List<CustomerModel>> readActiveCustomers();
  Future<CustomerModel> readCustomerById(String id);
  Future<void> createCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> activateCustomer(String id);
  Future<void> deactivateCustomer(String id);
  Future<void> hardDeleteCustomer(String id);
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
          .from('customers')
          .select(
            'id, name, phone, gender, description, created_at, updated_at, deleted_at',
          )
          .order('created_at', ascending: false);

      return response.map((e) => CustomerModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CustomerModel>> readActiveCustomers() async {
    try {
      final List<Map<String, dynamic>> response = await supabaseClient
          .from('customers')
          .select(
            'id, name, phone, gender, description, created_at, updated_at, deleted_at',
          )
          .filter('deleted_at', 'is', null)
          .order('created_at', ascending: false);

      return response.map((e) => CustomerModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CustomerModel> readCustomerById(String id) async {
    try {
      final Map<String, dynamic> response = await supabaseClient
          .from('customers')
          .select(
            'id, name, phone, gender, description, created_at, updated_at, deleted_at',
          )
          .eq('id', id)
          .single();
      return CustomerModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> createCustomer(CustomerModel customer) async {
    try {
      await supabaseClient.from('customers').insert(customer.toJson().cleanNulls());
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await supabaseClient.from('customers').update(customer.toJson().cleanNulls()).eq('id', customer.id!);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> activateCustomer(String id) async {
    try {
      await supabaseClient.from('customers').update({'deleted_at': null}).eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deactivateCustomer(String id) async {
    try {
      await supabaseClient.from('customers').update({'deleted_at': DateTime.now().toIso8601String()}).eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> hardDeleteCustomer(String id) async {
    try {
      await supabaseClient.from('customers').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
