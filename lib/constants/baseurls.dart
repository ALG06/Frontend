import 'dart:io';
import 'package:flutter/foundation.dart';

class EnvironmentConfig {
  static String get baseApiUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }

    if (Platform.isAndroid) {
      if (isRunningOnEmulator) {
        return 'http://10.0.2.2:5000';
      }
      return 'http://$_customIp:5000';
    }

    if (Platform.isIOS) {
      if (isRunningOnSimulator) {
        return 'http://localhost:5000';
      }
      return 'http://192.168.1.XXX:5000';
    }

    return 'http://localhost:5000';
  }

  static bool get isRunningOnEmulator {
    if (!Platform.isAndroid) return false;

    try {
      return Platform.environment.containsKey('ANDROID_EMULATOR') ||
          Platform.environment.containsKey('ANDROID_SDK_ROOT');
    } catch (e) {
      debugPrint('Error checking emulator status: $e');
      return false;
    }
  }

  static bool get isRunningOnSimulator {
    if (!Platform.isIOS) return false;

    try {
      return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME') ||
          Platform.environment.containsKey('SIMULATOR_HOST_HOME');
    } catch (e) {
      debugPrint('Error checking simulator status: $e');
      return false;
    }
  }

  static String _customIp = '';
  static void setCustomIp(String ip) {
    _customIp = ip;
  }

  static String getUrl(String endpoint) {
    String url = baseApiUrl;
    if (endpoint.startsWith('/')) {
      url = url + endpoint;
    } else {
      url = url + '/' + endpoint;
    }
    return url;
  }

  static const bool isDevelopment = true;

  static void printEnvironmentInfo() {
    debugPrint('Current Environment Configuration:');
    debugPrint('Base API URL: $baseApiUrl');
    debugPrint('Platform: ${Platform.operatingSystem}');
    debugPrint(
        'Is Emulator/Simulator: ${isRunningOnEmulator || isRunningOnSimulator}');
    debugPrint('Is Development: $isDevelopment');
  }
}
