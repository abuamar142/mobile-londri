// ignore_for_file: avoid_print

enum Environment {
  development,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.development;
  static Map<String, String> _config = {};

  static Environment get environment => _environment;
  static Map<String, String> get config => _config;

  static void setEnvironment(Environment env, Map<String, String> envConfig) {
    _environment = env;
    _config = envConfig;
  }

  static String get supabaseUrl => _config['SUPABASE_URL'] ?? '';
  static String get supabaseKey => _config['SUPABASE_KEY'] ?? '';
  static String get envType => _config['ENV_TYPE'] ?? 'development';
  static String get appName => _config['APP_NAME'] ?? 'Londri';
  static bool get debugMode => _config['DEBUG_MODE']?.toLowerCase() == 'true';

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isProduction => _environment == Environment.production;

  static String get environmentName {
    switch (_environment) {
      case Environment.development:
        return 'Development';
      case Environment.production:
        return 'Production';
    }
  }

  static String get appDisplayName => appName;
  static String getSupabaseUrl() => supabaseUrl;
  static String getSupabaseKey() => supabaseKey;

  /// Check if Supabase credentials are properly configured
  static bool get hasValidSupabaseCredentials {
    return supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
  }

  static void logConfig() {
    if (debugMode) {
      print('=== Environment Configuration ===');
      print('🌍 Environment: $environmentName');
      print('📱 App Name: $appName');
      print('🌐 Supabase URL: $supabaseUrl');
      print('🔧 Debug Mode: $debugMode');
      print('=================================');
    }
  }
}
