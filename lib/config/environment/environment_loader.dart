// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/services.dart';

import 'environment_config.dart';

class EnvironmentLoader {
  static Future<void> loadEnvironment(Environment environment) async {
    try {
      String envFileName;
      switch (environment) {
        case Environment.development:
          envFileName = '.env.dev';
          break;
        case Environment.production:
          envFileName = '.env.prod';
          break;
      } // Try to load from assets first (for release builds)
      Map<String, String> envConfig = {};
      bool loadedSuccessfully = false;
      try {
        final envString = await rootBundle.loadString(envFileName);
        envConfig = _parseEnvString(envString);
        loadedSuccessfully = true;
        print('✅ Environment loaded from assets: $envFileName');
      } catch (e) {
        // If assets loading fails, try to load from file system (for debug builds)
        try {
          final file = File(envFileName);
          if (await file.exists()) {
            final envString = await file.readAsString();
            envConfig = _parseEnvString(envString);
            loadedSuccessfully = true;
            print('✅ Environment loaded from file system: $envFileName');
          } else {
            throw Exception('Environment file $envFileName not found in file system');
          }
        } catch (fileError) {
          throw Exception('Failed to load environment configuration:\n'
              '- Assets loading error: $e\n'
              '- File system loading error: $fileError\n'
              '- Required file: $envFileName\n'
              '- Please ensure the environment file exists and is properly configured');
        }
      }

      // Validate that essential configuration is present
      if (!loadedSuccessfully || !_validateConfig(envConfig)) {
        throw Exception('Invalid environment configuration in $envFileName:\n'
            '- Missing required fields: SUPABASE_URL, SUPABASE_KEY\n'
            '- Please check your environment file configuration');
      }
      EnvironmentConfig.setEnvironment(environment, envConfig);
      EnvironmentConfig.logConfig();
    } catch (e) {
      // Re-throw the error instead of using default configuration
      throw Exception('Critical Error: Failed to initialize environment configuration!\n'
          'Error: $e\n'
          'Environment: ${environment.name}\n'
          'Action Required: Please check your environment files (.env.dev or .env.prod) and ensure they exist with proper configuration.');
    }
  }

  static Map<String, String> _parseEnvString(String envString) {
    final Map<String, String> envConfig = {};
    final lines = envString.split('\n');

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final separatorIndex = line.indexOf('=');
      if (separatorIndex == -1) continue;

      final key = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 1).trim();

      envConfig[key] = value;
    }

    return envConfig;
  }

  /// Validate that essential configuration keys are present and not empty
  static bool _validateConfig(Map<String, String> config) {
    final requiredKeys = ['SUPABASE_URL', 'SUPABASE_KEY'];

    for (String key in requiredKeys) {
      if (!config.containsKey(key) || config[key]?.isEmpty == true) {
        print('❌ Missing or empty required configuration: $key');
        return false;
      }
    }

    // Additional validation for URL format
    final supabaseUrl = config['SUPABASE_URL'];
    if (supabaseUrl != null && !supabaseUrl.contains('supabase.co')) {
      print('❌ Invalid Supabase URL format: $supabaseUrl');
      return false;
    }

    return true;
  }
}
