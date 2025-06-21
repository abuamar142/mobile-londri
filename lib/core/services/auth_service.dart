import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabaseClient;

  AuthService({
    required this.supabaseClient,
  });

  /// Check if user is currently authenticated
  bool get isAuthenticated => supabaseClient.auth.currentSession != null;

  /// Get current user
  User? get currentUser => supabaseClient.auth.currentUser;

  /// Get current session
  Session? get currentSession => supabaseClient.auth.currentSession;

  /// Initialize auth listener and restore session
  Future<void> initializeAuthListener() async {
    // Check if there's already a stored session
    final session = supabaseClient.auth.currentSession;
    if (session != null) {
      if (kDebugMode) {
        print('🔄 Session restored: ${session.user.email}');
        print('🔑 Token: ${session.accessToken.substring(0, 20)}...');
      }
    }

    // Listen to auth state changes
    supabaseClient.auth.onAuthStateChange.listen((data) async {
      final Session? session = data.session;
      final AuthChangeEvent event = data.event;

      if (kDebugMode) {
        print('🔄 Auth event: $event');
      }

      switch (event) {
        case AuthChangeEvent.signedIn:
          if (session != null) {
            if (kDebugMode) {
              print('✅ User signed in: ${session.user.email}');
              print('🔑 Token: ${session.accessToken.substring(0, 20)}...');
              print('⏰ Expires at: ${DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)}');
            }
          }
          break;
        case AuthChangeEvent.signedOut:
          if (kDebugMode) {
            print('🚪 User signed out');
          }
          break;
        case AuthChangeEvent.tokenRefreshed:
          if (session != null) {
            if (kDebugMode) {
              print('� Token refreshed for: ${session.user.email}');
              print('🔑 New token: ${session.accessToken.substring(0, 20)}...');
            }
          }
          break;
        case AuthChangeEvent.userUpdated:
          if (kDebugMode) {
            print('👤 User updated');
          }
          break;
        default:
          break;
      }
    });
  }

  /// Refresh the current session
  Future<AuthResponse> refreshSession() async {
    return await supabaseClient.auth.refreshSession();
  }

  /// Get current user's ID from public.users table
  Future<int?> getCurrentUserId() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await supabaseClient.from('users').select('id').eq('user_id', user.id).single();

      return response['id'] as int?;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user ID: $e');
      }
      return null;
    }
  }
}
