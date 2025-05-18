import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:londri/core/error/exceptions.dart';
import 'package:londri/features/service/data/datasources/service_remote_datasource.dart';
import 'package:londri/features/service/data/models/service_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final supabaseClient = SupabaseClient(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_KEY']!,
    headers: {
      'Authorization': 'Bearer ${dotenv.env['SUPABASE_TOKEN']!}',
    },
  );

  final ServiceRemoteDatasourceImplementation datasource =
      ServiceRemoteDatasourceImplementation(
    supabaseClient: supabaseClient,
  );

  await getServices(datasource: datasource);
  // await getServiceById(datasource: datasource, id: dotenv.env['SERVICE_ID']!);
  // await createService(datasource: datasource);
  // await updateService(datasource: datasource);
  // await deleteService(datasource: datasource);
}

Future<void> getServices({
  required ServiceRemoteDatasourceImplementation datasource,
}) async {
  try {
    final response = await datasource.readServices();

    log(response.toString());
  } on ServerException catch (e) {
    log(e.message);
  } catch (e) {
    log(e.toString());
  }
}

Future<void> getServiceById({
  required ServiceRemoteDatasourceImplementation datasource,
  required String id,
}) async {
  try {
    final response = await datasource.readServiceById(id);

    log(response.toString());
  } on ServerException catch (e) {
    log(e.message);
  } catch (e) {
    log(e.toString());
  }
}

Future<void> createService({
  required ServiceRemoteDatasourceImplementation datasource,
}) async {
  try {
    final ServiceModel data = ServiceModel(
      id: Uuid().v4(),
      name: 'Coba',
      price: 7000,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    log('data $data');

    await datasource.createService(data);
  } on ServerException catch (e) {
    log(e.message);
  } catch (e) {
    log(e.toString());
  }
}

Future<void> updateService({
  required ServiceRemoteDatasourceImplementation datasource,
}) async {
  try {
    final ServiceModel data = ServiceModel(
      id: dotenv.env['SERVICE_ID']!,
      name: 'Biasa',
      updatedAt: DateTime.now(),
    );

    log('data ${data.toUpdateJson(data)}');

    await datasource.updateService(data);
  } on ServerException catch (e) {
    log(e.message);
  } catch (e) {
    log(e.toString());
  }
}

Future<void> deleteService({
  required ServiceRemoteDatasourceImplementation datasource,
}) async {
  try {
    await datasource.deleteService(
      dotenv.env['SERVICE_ID']!,
    );
  } on ServerException catch (e) {
    log(e.message);
  } catch (e) {
    log(e.toString());
  }
}
