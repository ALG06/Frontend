import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class EnvironmentService {
  static const platform = MethodChannel('com.example.app/environment');
  static bool _initialized = false;

  static Future<String?> getMapsApiKey() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final String? result = await platform.invokeMethod('getApiKey');
        return result;
      }
    } catch (e) {
      debugPrint('Error getting API key: $e');
    }
    return null;
  }

  static Future<void> initGoogleMaps() async {
    if (_initialized) return;

    try {
      String? apiKey;

      // In debug mode, use the .env file
      if (kDebugMode) {
        apiKey = const String.fromEnvironment('MAPS_API_KEY',
            defaultValue: 'default_value_here');
      } else {
        apiKey = await getMapsApiKey();
      }

      if (apiKey == null) {
        throw Exception('Failed to get Maps API key');
      }

      final result = await platform.invokeMethod('initGoogleMaps', apiKey);
      if (result == true) {
        _initialized = true;
        debugPrint('Google Maps initialized successfully');
      }
    } catch (e) {
      debugPrint('Error initializing Google Maps: $e');
      rethrow;
    }
  }
}
