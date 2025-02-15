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

  try {
    final response = await datasource.readProfile();

    print(response);
  } on ServerException catch (e) {
    print(e.message);
  } catch (e) {
    print(e);
  }
}
