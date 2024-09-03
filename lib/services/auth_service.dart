import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  String? _email;
  String? _name;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;
  String? get name => _name;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  static const String baseUrl = 'http://your-flask-backend.com';

  Future<void> initiateGoogleSignIn() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(Uri.parse('$baseUrl/auth/login/google'));
      final data = json.decode(response.body);

      if (data['auth_url'] != null) {
        await launchUrl(Uri.parse(data['auth_url']));
      }
    } catch (e) {
      throw Exception('Failed to initiate Google Sign In: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleAuthCallback(Uri uri) async {
    try {
      final code = uri.queryParameters['code'];
      if (code != null) {
        final response = await http.get(
          Uri.parse('$baseUrl/auth/login/google/callback?code=$code'),
        );

        final data = json.decode(response.body);
        await _handleAuthSuccess(data);
      }
    } catch (e) {
      throw Exception('Failed to handle auth callback: $e');
    }
  }

  Future<void> _handleAuthSuccess(Map<String, dynamic> data) async {
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
  }

  Future<bool> refreshAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Authorization': 'Bearer $_refreshToken'},
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
      return false;
    }
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _email = null;
    _name = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    _email = prefs.getString('email');
    _name = prefs.getString('name');

    if (_accessToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/auth/verify'),
          headers: {'Authorization': 'Bearer $_accessToken'},
        );
        _isAuthenticated = response.statusCode == 200;
      } catch (e) {
        _isAuthenticated = false;
      }
    } else {
      _isAuthenticated = false;
    }

    notifyListeners();
  }
}
