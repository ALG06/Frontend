import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';

class AuthService extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  String? _email;
  String? _name;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;
  String? get name => _name;
  bool get isLoading => _isLoading;

  // Constants
  static const String baseUrl = 'http://127.0.0.1:5000';
  static const String redirectUri = 'bamxapp://login';

  // Initialize deep linking
  Future<void> initDeepLinks() async {
    // Handle incoming links when app is running
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        handleAuthCallback(uri);
      }
    }, onError: (err) {
      debugPrint('Deep link error: $err');
    });

    // Handle incoming links when app was terminated
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        handleAuthCallback(initialUri);
      }
    } catch (e) {
      debugPrint('Initial deep link error: $e');
    }
  }

  Future<void> initiateGoogleSignIn() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl/auth/login/google?redirect_uri=$redirectUri'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to initialize Google Sign In: ${response.body}');
      }

      final data = json.decode(response.body);

      if (data['auth_url'] != null) {
        final Uri authUrl = Uri.parse(data['auth_url']);
        if (await canLaunchUrl(authUrl)) {
          await launchUrl(
            authUrl,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw Exception('Could not launch auth URL');
        }
      } else {
        throw Exception('No auth URL provided');
      }
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      throw Exception('Failed to initiate Google Sign In: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleAuthCallback(Uri uri) async {
    try {
      _isLoading = true;
      notifyListeners();

      final code = uri.queryParameters['code'];
      if (code != null) {
        final response = await http.get(
          Uri.parse('$baseUrl/auth/login/google/callback?code=$code'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode != 200) {
          throw Exception('Auth callback failed: ${response.body}');
        }

        final data = json.decode(response.body);
        await _handleAuthSuccess(data);
      }
    } catch (e) {
      debugPrint('Auth Callback Error: $e');
      throw Exception('Failed to handle auth callback: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleAuthSuccess(Map<String, dynamic> data) async {
    try {
      _accessToken = data['access_token'];
      _refreshToken = data['refresh_token'];
      _email = data['email'];
      _name = data['name'];
      _isAuthenticated = true;

      // Store tokens securely
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _accessToken!);
      await prefs.setString('refresh_token', _refreshToken!);
      await prefs.setString('email', _email!);
      await prefs.setString('name', _name!);

      notifyListeners();
    } catch (e) {
      debugPrint('Handle Auth Success Error: $e');
      throw Exception('Failed to handle auth success: $e');
    }
  }

  Future<bool> refreshAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Authorization': 'Bearer $_refreshToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Refresh Token Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _accessToken = null;
      _refreshToken = null;
      _email = null;
      _name = null;
      _isAuthenticated = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      notifyListeners();
    } catch (e) {
      debugPrint('Logout Error: $e');
      throw Exception('Failed to logout: $e');
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
      _email = prefs.getString('email');
      _name = prefs.getString('name');

      if (_accessToken != null) {
        final response = await http.get(
          Uri.parse('$baseUrl/auth/verify'),
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
        );
        _isAuthenticated = response.statusCode == 200;
      } else {
        _isAuthenticated = false;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Check Auth Status Error: $e');
      _isAuthenticated = false;
      notifyListeners();
    }
  }
}
