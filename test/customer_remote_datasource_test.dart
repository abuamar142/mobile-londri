import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:londri/core/error/exceptions.dart';
import 'package:londri/core/services/auth_service.dart';
import 'package:londri/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:londri/features/customers/data/datasources/customer_remote_datasource.dart';
import 'package:londri/features/customers/data/models/customer_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final supabaseClient = SupabaseClient(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_KEY']!,
  );

  await AuthService(
    supabaseClient: supabaseClient,
  ).initializeAuthListener();

  final AuthRemoteDatasourceImplementation authDataSource =
      AuthRemoteDatasourceImplementation(
    supabaseClient: supabaseClient,
  );

  await authDataSource.login(
    dotenv.env['USER_EMAIL']!,
    dotenv.env['USER_PASSWORD']!,
  );

  final CustomerRemoteDatasourceImplementation datasource =
      CustomerRemoteDatasourceImplementation(
    supabaseClient: supabaseClient,
  );

  await getCustomers(datasource: datasource);
  // await getCustomerById(
  //   datasource: datasource,
  //   id: 'a0058e2f-566f-4fb8-8cbf-d1d632bd6e50',
  // );
  // await createCustomer(datasource: datasource);
  // await updateCustomer(datasource: datasource);
  // await deleteCustomer(datasource: datasource);
}

Future<void> getCustomers({
  required CustomerRemoteDatasourceImplementation datasource,
}) async {
  try {
    final response = await datasource.readCustomers();

    log(response.toString());
  } on ServerException catch (e) {
    log(e.message);
  } catch (e) {
    log(e.toString());
  }
}

Future<void> getCustomerById({
  required CustomerRemoteDatasourceImplementation datasource,
  required String id,
}) async {
  try {
    final response = await datasource.readCustomerById(id);

    log(response.toString());
  } on ServerException catch (e) {
    log(e.message);
  } catch (e) {
    log(e.toString());
  }
}

Future<void> createCustomer({
  required CustomerRemoteDatasourceImplementation datasource,
}) async {
  try {
    final CustomerModel data = CustomerModel(
      id: Uuid().v4(),
      name: 'Customer 3',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    log('data $data');

    await datasource.createCustomer(data);
  } on ServerException catch (e) {
    log(e.message);
  } catch (e) {
    log(e.toString());
  }
}

Future<void> updateCustomer({
  required CustomerRemoteDatasourceImplementation datasource,
}) async {
  try {
    final CustomerModel data = CustomerModel(
      id: '703615ff-a2d7-46f1-ac84-eda07c6800c5',
      name: 'Customer 3 Updated',
      updatedAt: DateTime.now(),
    );

    log('data ${data.toUpdateJson(data)}');

    await datasource.updateCustomer(data);
  } on ServerException catch (e) {
    log(e.message);
  } catch (e) {
    log(e.toString());
  }
}

Future<void> deleteCustomer({
  required CustomerRemoteDatasourceImplementation datasource,
}) async {
  try {
    await datasource.deleteCustomer(
      '703615ff-a2d7-46f1-ac84-eda07c6800c5',
    );
  } on ServerException catch (e) {
    log(e.message);
  } catch (e) {
    log(e.toString());
  }
}
