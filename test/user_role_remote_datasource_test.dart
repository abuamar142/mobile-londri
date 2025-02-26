import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:londri/core/error/exceptions.dart';
import 'package:londri/features/user_role/data/datasources/user_role_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final UserRoleRemoteDataSourceImplementation datasource =
      UserRoleRemoteDataSourceImplementation(
    supabaseClient: supabaseClient,
  );

  // await createUserRole(datasource: datasource);
  await readProfile(datasource: datasource);
  // await deleteUserRole(datasource: datasource);
}

Future<void> createUserRole({
  required UserRoleRemoteDataSourceImplementation datasource,
}) async {
  try {
    await datasource.createUserRole(
      dotenv.env['USER_ID']!,
    );

    print("Success");
  } on ServerException catch (e) {
    print(e.message);
  } catch (e) {
    print(e);
  }
}

Future<void> readProfile({
  required UserRoleRemoteDataSourceImplementation datasource,
}) async {
  try {
    final response = await datasource.readProfiles();

    print(response);
  } on ServerException catch (e) {
    print(e.message);
  } catch (e) {
    print(e);
  }
}

Future<void> deleteUserRole({
  required UserRoleRemoteDataSourceImplementation datasource,
}) async {
  try {
    await datasource.deleteUserRole(
      dotenv.env['USER_ID']!,
    );

    print("Success");
  } on ServerException catch (e) {
    print(e.message);
  } catch (e) {
    print(e);
  }
}
