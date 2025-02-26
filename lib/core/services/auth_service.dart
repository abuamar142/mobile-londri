import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabaseClient;

  AuthService({
    required this.supabaseClient,
  });

  Future<void> initializeAuthListener() async {
    supabaseClient.auth.onAuthStateChange.listen((data) async {
      final Session? session = data.session;

      if (session != null) {
        if (kDebugMode) {
          print('🔑 Token updated : ${session.accessToken}');
        }
      } else {
        if (kDebugMode) {
          print('🚪 Token removed');
        }
      }
    });
  }
}
